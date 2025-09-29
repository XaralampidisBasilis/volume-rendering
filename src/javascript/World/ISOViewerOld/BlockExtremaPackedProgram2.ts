import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'


const trilinearCode = (inputShape: [number, number, number, number, number], inputStride: number) => `

    // Compute the min and max values of the trilinear interpolation inside a single cell
    vec2 computeCellExtrema(int cellX, int cellY, int cellZ)
    {
        float minValue = 1.0;
        float maxValue = 0.0;

        for (int localX = 0; localX < 2; ++localX) {
        for (int localY = 0; localY < 2; ++localY) {
        for (int localZ = 0; localZ < 2; ++localZ) {
            
            int voxelX = clamp(cellX - 1 + localX, 0, ${inputShape[0] - 1});
            int voxelY = clamp(cellY - 1 + localY, 0, ${inputShape[1] - 1});
            int voxelZ = clamp(cellZ - 1 + localZ, 0, ${inputShape[2] - 1});
            
            float voxelValue = getA(voxelX, voxelY, voxelZ, 0, 0).a; // F

            minValue = min(minValue, voxelValue);
            maxValue = max(maxValue, voxelValue);

        }}}
        
        return vec2(minValue, maxValue);
    }

    // Compute the extrema across all cells in a block
    vec2 computeBlockExtrema(int blockX, int blockY, int blockZ)
    {
        int startX = blockX * ${inputStride};
        int startY = blockY * ${inputStride};
        int startZ = blockZ * ${inputStride};

        int endX = startX + ${inputStride};
        int endY = startY + ${inputStride};
        int endZ = startZ + ${inputStride};

        float minValue = 1.0;
        float maxValue = 0.0;

        for (int cellX = startX; cellX < endX; ++cellX) {
        for (int cellY = startY; cellY < endY; ++cellY) {
        for (int cellZ = startZ; cellZ < endZ; ++cellZ) {
            
            vec2 cellExtrema = computeCellExtrema(cellX, cellY, cellZ);

            minValue = min(minValue, cellExtrema.x);
            maxValue = max(maxValue, cellExtrema.y);

        }}}

        minValue = clamp(minValue, 0.0, 1.0);
        maxValue = clamp(maxValue, 0.0, 1.0);

        return vec2(minValue, maxValue);
    }

    void main()
    {
        ivec4 outputCoords = getOutputCoords();

        int blockX = outputCoords.x;
        int blockY = outputCoords.y;
        int blockZ = outputCoords.z;

        vec2 blockExtrema = computeBlockExtrema(blockX, blockY, blockZ);
        setOutput(vec4(blockExtrema, 0.0, 0.0));
    }
`
const tricubicCode = (inputShape: [number, number, number, number, number], inputStride: number) => `
    
    const ivec3 voxelMinCoords = ivec3(0);
    const ivec3 voxelMaxCoords = ivec3(${inputShape[2]-1}, ${inputShape[1]-1}, ${inputShape[0]-1});

    const mat2x4 Elevations = mat2x4(
        1.0, 2.0/3.0, 1.0/3.0, 0.0,   
        0.0, 1.0/3.0, 2.0/3.0, 1.0
    );

    const mat2x4 Contributions = mat2x4(
        0.0, -0.25,  0.0,  0.0,  
        0.0,  0.0, -0.25,  0.0
    );

    vec4 getVoxelSample(in ivec3 voxelCoords)
    {
        voxelCoords = clamp(voxelCoords, voxelMinCoords, voxelMaxCoords);
        return getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0, 0);
    }

    void getVoxelSamplesAtCell(in ivec3 cellCoords, out vec4[8] voxelSamplesAtCell)
    {
        for (int r = 0; r < 2; r++) {
        for (int q = 0; q < 2; q++) {
        for (int p = 0; p < 2; p++) {

            int pqr = p + q*2 + r*4;
            ivec3 voxelCoords = cellCoords + ivec3(p, q, r) - 1;
            voxelSamplesAtCell[pqr] = getVoxelSample(voxelCoords);

        }}}
    }
    
    float getBernsteinCoeffAtCell(in ivec3 coeffIndices, in vec4[8] voxelSamplesAtCell)
    {
        float bernsteinCoeff = 0.0;

        int u = coeffIndices.x;
        int v = coeffIndices.y;
        int w = coeffIndices.z;

        for (int r = 0; r < 2; r++) 
        {
            float Mz = Contributions[r][w];
            float Wz = Elevations[r][w];

        for (int q = 0; q < 2; q++) 
        {
            float My = Contributions[q][v];
            float Wy = Elevations[q][v];

        for (int p = 0; p < 2; p++) 
        {
            float Mx = Contributions[p][u];
            float Wx = Elevations[p][u];

            int pqr = p + q*2 + r*4;
            
            vec4  V = voxelSamplesAtCell[pqr];
            vec4  M = vec4(Mx, My, Mz, 1.0);
            float W = Wx * Wy * Wz; 

            bernsteinCoeff += dot(V, M) * W;

        }}} 

        return bernsteinCoeff;
    }

    vec2 getCellExtrema(in ivec3 cellCoords)
    {
        vec4[8] voxelSamplesAtCell;
        vec2 cellMinMax = vec2(1.0, 0.0);

        getVoxelSamplesAtCell(cellCoords, voxelSamplesAtCell);
        
        for (int w = 0; w < 4; w++) {
        for (int v = 0; v < 4; v++) {
        for (int u = 0; u < 4; u++) {

            ivec3 coeffIndices = ivec3(u, v, w);
            float bernsteinCoeff = getBernsteinCoeffAtCell(coeffIndices, voxelSamplesAtCell);
            
            cellMinMax.x = min(cellMinMax.x, bernsteinCoeff);
            cellMinMax.y = max(cellMinMax.y, bernsteinCoeff);

        }}} 

        return cellMinMax;
    }

    // Compute extrema over all cells in the block
    vec2 getBlockExtrema(ivec3 blockCoords)
    {
        vec2 blockMinMax = vec2(1.0, 0.0);
        ivec3 cellMinCoords = blockCoords * ${inputStride};

        for (int k = 0; k < ${inputStride}; k++) {
        for (int j = 0; j < ${inputStride}; j++) {
        for (int i = 0; i < ${inputStride}; i++) {

            ivec3 cellIndices = ivec3(i, j, k);
            ivec3 cellCoords = cellMinCoords + cellIndices;
            vec2 cellMinMax = getCellExtrema(cellCoords);

            blockMinMax.x = min(blockMinMax.x, cellMinMax.x);
            blockMinMax.y = max(blockMinMax.y, cellMinMax.y);

        }}}

        return blockMinMax;
    }

    void main()
    {
        ivec5 outputCoords = getOutputCoords();

        ivec3 blockCoords = ivec3(outputCoords.z, outputCoords.y, outputCoords.x);
        vec2 blockMinMax = getBlockExtrema(blockCoords);

        blockMinMax = clamp(blockMinMax, 0.0, 1.0);
        setOutput(vec4(blockMinMax, 0.0, 0.0));
    }
`

class BlockExtremaPackedProgram implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor(inputShape: [number, number, number, number, number], inputStride: number, inputMethod: number) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const [outDepth, outHeight, outWidth] = [inDepth, inHeight, inWidth].map((inDimension) => Math.ceil((inDimension + 1) / inputStride))
        this.outputShape = [outDepth, outHeight, outWidth, 2, 2]
        this.userCode = (inputMethod == 0) ? trilinearCode(inputShape, inputStride) : tricubicCode(inputShape, inputStride) 
    }
}

export function blockExtremaPackedProgram(inputPackedTensor: tf.Tensor5D, inputStride: number, inputMethod = 1) : tf.Tensor5D
{
    const inputShape = inputPackedTensor.shape
    const program = new BlockExtremaPackedProgram(inputShape, inputStride, inputMethod)
    const backend = tf.backend() as MathBackendWebGL
    const result = backend.compileAndRun(program, [inputPackedTensor])
    return tf.engine().makeTensorFromTensorInfo(result) as tf.Tensor5D
}