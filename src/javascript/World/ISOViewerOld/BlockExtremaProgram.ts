import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'


const trilinearCode = (inputShape: number[], inputStride: number) => `

    // Compute the min and max values of the trilinear interpolation inside a single cell
    vec2 computeCellExtrema(int cellX, int cellY, int cellZ)
    {
        float minValue = 1.0;
        float maxValue = 0.0;

        for (int localZ = 0; localZ < 2; ++localZ) {
        for (int localY = 0; localY < 2; ++localY) {
        for (int localX = 0; localX < 2; ++localX) {
        
            int voxelZ = clamp(cellZ - 1 + localZ, 0, ${inputShape[2] - 1});
            int voxelY = clamp(cellY - 1 + localY, 0, ${inputShape[1] - 1});
            int voxelX = clamp(cellX - 1 + localX, 0, ${inputShape[0] - 1});
            
            float voxelValue = getA(voxelX, voxelY, voxelZ, 3); // raw scalar value

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

        for (int cellZ = startZ; cellZ < endZ; ++cellZ) {
        for (int cellY = startY; cellY < endY; ++cellY) {
        for (int cellX = startX; cellX < endX; ++cellX) {
            
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

        int outputChannel = outputCoords.w;
        if (outputChannel == 0) 
        {
            setOutput(blockExtrema.x); // min value
        } 
        else 
        {
            setOutput(blockExtrema.y); // max value
        }
    }
`
const tricubicCode = (inputShape: number[], inputStride: number) => `
    
    const ivec3 maxVoxelCoords = ivec3(${inputShape[2]-1}, ${inputShape[1]-1}, ${inputShape[0]-1});

    const mat2x4 Elevations = mat2x4(
        1.0, 2.0/3.0, 1.0/3.0, 0.0,   
        0.0, 1.0/3.0, 2.0/3.0, 1.0
    );

    const mat2x4 Contributions = mat2x4(
        0.0, -0.25,  0.0,  0.0,  
        0.0,  0.0, -0.25,  0.0
    );

    vec4 getVoxelSample(ivec3 voxelCoords)
    {
        voxelCoords = clamp(voxelCoords, ivec3(0), maxVoxelCoords);
        
        return vec4(
            getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0), // fxx
            getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 1), // fyy
            getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 2), // fzz
            getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 3)  // f
        );
    }
    
    float getBernsteinCoeff(ivec3 cellCoords, ivec3 coeffIndices)
    {
        float bernsteinCoeff = 0.0;

        int u = coeffIndices.x;
        int v = coeffIndices.y;
        int w = coeffIndices.z;

        for (int r = 0; r < 2; r++) {
        for (int q = 0; q < 2; q++) {
        for (int p = 0; p < 2; p++) {

            ivec3 localCoords = ivec3(p, q, r) - 1;
            ivec3 voxelCoords = cellCoords + localCoords;

            vec4 voxelSample = getVoxelSample(voxelCoords);

            float Wx = Elevations[p][u];
            float Wy = Elevations[q][v];
            float Wz = Elevations[r][w];
            float W = Wx * Wy * Wz;

            float Mx = Contributions[p][u];
            float My = Contributions[q][v];
            float Mz = Contributions[r][w];
            vec4 M = vec4(Mx, My, Mz, 1.0);

            bernsteinCoeff += dot(voxelSample, M) * W;

        }}} 

        return bernsteinCoeff;
    }

    vec2 getCellExtrema(ivec3 cellCoords)
    {
        vec2 cellMinMax = vec2(1.0, 0.0);
        
        for (int w = 0; w < 4; w++) {
        for (int v = 0; v < 4; v++) {
        for (int u = 0; u < 4; u++) {

            ivec3 coeffIndices = ivec3(u, v, w);
            float bernsteinCoeff = getBernsteinCoeff(cellCoords, coeffIndices);
            
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

            ivec3 cellIndices = ivec3(i, j, j);
            ivec3 cellCoords = cellMinCoords + cellIndices;

            vec2 cellMinMax = getCellExtrema(cellCoords);

            blockMinMax.x = min(blockMinMax.x, cellMinMax.x);
            blockMinMax.y = max(blockMinMax.y, cellMinMax.y);

        }}}

        return blockMinMax;
    }

    void main()
    {
        ivec4 outputCoords = getOutputCoords();
        ivec3 blockCoords = outputCoords.zyx;
        
        vec2 blockMinMax = getBlockExtrema(blockCoords);
        blockMinMax = clamp(blockMinMax, 0.0, 1.0);

        setOutput((outputCoords.w == 0) ? blockMinMax.x : blockMinMax.y);
    }
`


class BlockExtremaProgram implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor(inputShape: number[], inputStride: number, inputMethod: number) 
    {
        this.outputShape = inputShape.map((inputDim) => Math.ceil((inputDim + 1) / inputStride))
        this.outputShape[3] = 2        
        this.userCode = (inputMethod == 0) 
        ? trilinearCode(inputShape, inputStride) 
        : tricubicCode(inputShape, inputStride) 
    }
}

export function blockExtremaProgram(inputTensor: tf.Tensor, inputStride: number, inputMethod = 1) : tf.Tensor4D
{
    const program = new BlockExtremaProgram(inputTensor.shape, inputStride, inputMethod)
    const backend = tf.backend() as MathBackendWebGL
    const result = backend.compileAndRun(program, [inputTensor])
    return tf.engine().makeTensorFromTensorInfo(result) as tf.Tensor4D
}