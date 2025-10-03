import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUExtremaMap implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number, number, number], 
        blockSize: number
    ) 
    {
        const ceilDiv = (x: number) => Math.ceil((x + 1) / blockSize)
        const [inDepth, inHeight, inWidth, , ] = inputShape
        const [outDepth, outHeight, outWidth] = [inDepth, inHeight, inWidth].map(ceilDiv)
        this.outputShape = [outDepth, outHeight, outWidth, 2, 2]         
        this.userCode = `
        const ivec3 voxelMinCoords = ivec3(0);
        const ivec3 voxelMaxCoords = ivec3(${inWidth-1}, ${inHeight-1}, ${inDepth-1});

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
            voxelCoords = clamp(voxelCoords, voxelMinCoords, voxelMaxCoords);
            return getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0, 0);
        }

        float getBernsteinCoefficient(ivec3 coeffIndices, ivec3 cellCoords)
        {
            float bernsteinCoefficient = 0.0;

            int u = coeffIndices.x;
            int v = coeffIndices.y;
            int w = coeffIndices.z;

            for (int r = 0; r < 2; r++) {
            for (int q = 0; q < 2; q++) {
            for (int p = 0; p < 2; p++) {

                ivec3 voxelIndices = ivec3(p, q, r) - 1;
                ivec3 voxelCoords = cellCoords + voxelIndices;
                vec4 V = getVoxelSample(voxelCoords);

                float Mx = Contributions[p][u];
                float My = Contributions[q][v];
                float Mz = Contributions[r][w];
                vec4 M = vec4(Mx, My, Mz, 1.0);

                float Wx = Elevations[p][u];
                float Wy = Elevations[q][v];
                float Wz = Elevations[r][w];
                float W = Wx * Wy * Wz;

                bernsteinCoefficient += dot(V, M) * W;

            }}} 

            return bernsteinCoefficient;
        }

        vec2 getCellExtremaTricubic(ivec3 cellCoords)
        {
            vec2 cellMinMax = vec2(1.0, 0.0);
            
            for (int w = 0; w < 4; w++) {
            for (int v = 0; v < 4; v++) {
            for (int u = 0; u < 4; u++) {

                ivec3 coeffIndices = ivec3(u, v, w);
                float bernsteinCoefficient = getBernsteinCoefficient(coeffIndices, cellCoords);
                
                cellMinMax.x = min(cellMinMax.x, bernsteinCoefficient);
                cellMinMax.y = max(cellMinMax.y, bernsteinCoefficient);

            }}} 

            return cellMinMax;
        }

        vec2 getCellExtremaTrilinear(ivec3 cellCoords)
        {
            vec2 cellMinMax = vec2(1.0, 0.0);

            for (int r = 0; r < 2; ++r) {
            for (int q = 0; q < 2; ++q) {
            for (int p = 0; p < 2; ++p) {
                
                ivec3 voxelIndices = ivec3(p, q, r) - 1;
                ivec3 voxelCoords = cellCoords + voxelIndices;
                float voxelValue = getVoxelSample(voxelCoords).a;
                
                cellMinMax.x = min(cellMinMax.x, voxelValue);
                cellMinMax.y = max(cellMinMax.y, voxelValue);

            }}}
            
            return cellMinMax;
        }
        

        // Compute extrema over all cells in the block
        vec4 getBlockExtrema(ivec3 blockCoords)
        {
            vec4 blockMinMaxMinMax = vec4(1.0, 0.0, 1.0, 0.0);
            vec4 cellMinMaxMinMax;

            ivec3 cellMinCoords = blockCoords * ${blockSize};

            for (int k = 0; k < ${blockSize}; k++) {
            for (int j = 0; j < ${blockSize}; j++) {
            for (int i = 0; i < ${blockSize}; i++) {

                ivec3 cellIndices = ivec3(i, j, k);
                ivec3 cellCoords = cellMinCoords + cellIndices;

                cellMinMaxMinMax.rg = getCellExtremaTrilinear(cellCoords);
                cellMinMaxMinMax.ba = getCellExtremaTricubic(cellCoords);
        
                blockMinMaxMinMax.xz = min(blockMinMaxMinMax.xz, cellMinMaxMinMax.xz);
                blockMinMaxMinMax.yw = max(blockMinMaxMinMax.yw, cellMinMaxMinMax.yw);

            }}}

            return blockMinMaxMinMax;
        }

        void main()
        {
            ivec5 outputCoords = getOutputCoords();
            ivec3 blockCoords = ivec3(outputCoords.z, outputCoords.y, outputCoords.x);

            vec4 blockMinMaxMinMax = getBlockExtrema(blockCoords);
            blockMinMaxMinMax = clamp(blockMinMaxMinMax, 0.0, 1.0);
            
            setOutput(blockMinMaxMinMax);
        }
        `
    }
}

class GPGPUExtremaMap_v2 implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number, number, number], 
        blockSize: number
    ) 
    {
        const ceilDiv = (x: number) => Math.ceil((x + 1) / blockSize)
        const [inDepth, inHeight, inWidth, , ] = inputShape
        const [outDepth, outHeight, outWidth] = [inDepth, inHeight, inWidth].map(ceilDiv)
        this.outputShape = [outDepth, outHeight, outWidth, 2, 2]         
        this.userCode = `
        const ivec3 voxelMinCoords = ivec3(0);
        const ivec3 voxelMaxCoords = ivec3(${inWidth-1}, ${inHeight-1}, ${inDepth-1});

        const mat2x4 Elevations = mat2x4(
            1.0, 2.0/3.0, 1.0/3.0, 0.0,   
            0.0, 1.0/3.0, 2.0/3.0, 1.0
        );

        const mat2x4 Contributions = mat2x4(
            0.0, -0.25,  0.0,  0.0,  
            0.0,  0.0, -0.25,  0.0
        );

        vec4 cellSamples[8];
  
        vec4 getVoxelSample(ivec3 voxelCoords)
        {
            voxelCoords = clamp(voxelCoords, voxelMinCoords, voxelMaxCoords);
            return getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0, 0);
        }
        
        void loadCellSamples(ivec3 cellCoords)
        {
            for (int r = 0; r < 2; r++) {
            for (int q = 0; q < 2; q++) {
            for (int p = 0; p < 2; p++) {

                int voxelIndex = p + q * 2 + r * 4;
                ivec3 voxelIndices = ivec3(p-1, q-1, r-1);
                ivec3 voxelCoords = cellCoords + voxelIndices;
                cellSamples[voxelIndex] = getVoxelSample(voxelCoords);

            }}} 
        }
   
        float getBernsteinCoefficient(ivec3 coeffIndices)
        {
            float bernsteinCoefficient = 0.0;

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

                vec4  M = vec4(Mx, My, Mz, 1.0);
                float W = Wx * Wy * Wz;

                int voxelIndex = p + q * 2 + r * 4;
                vec4  V = cellSamples[voxelIndex];

                bernsteinCoefficient += dot(V, M) * W;

            }}} 

            return bernsteinCoefficient;
        }

        vec2 getCellExtremaTricubic()
        {
            vec2 cellMinMax = vec2(1.0, 0.0);
            
            for (int w = 0; w < 4; w++) {
            for (int v = 0; v < 4; v++) {
            for (int u = 0; u < 4; u++) {

                ivec3 coeffIndices = ivec3(u, v, w);
                float bernsteinCoefficient = getBernsteinCoefficient(coeffIndices);
                
                cellMinMax.x = min(cellMinMax.x, bernsteinCoefficient);
                cellMinMax.y = max(cellMinMax.y, bernsteinCoefficient);

            }}} 

            return cellMinMax;
        }

        vec2 getCellExtremaTrilinear()
        {
            vec2 cellMinMax = vec2(1.0, 0.0);

            for (int r = 0; r < 2; ++r) {
            for (int q = 0; q < 2; ++q) {
            for (int p = 0; p < 2; ++p) {
                
                int voxelIndex = p + q * 2 + r * 4;
                float voxelValue = cellSamples[voxelIndex].a;
                
                cellMinMax.x = min(cellMinMax.x, voxelValue);
                cellMinMax.y = max(cellMinMax.y, voxelValue);

            }}}
            
            return cellMinMax;
        }

        // Compute extrema over all cells in the block
        vec4 getBlockExtrema(ivec3 blockCoords)
        {
            vec4 blockMinMaxMinMax = vec4(1.0, 0.0, 1.0, 0.0);
            vec4 cellMinMaxMinMax;

            ivec3 cellMinCoords = blockCoords * ${blockSize};

            for (int k = 0; k < ${blockSize}; k++) {
            for (int j = 0; j < ${blockSize}; j++) {
            for (int i = 0; i < ${blockSize}; i++) {

                ivec3 cellIndices = ivec3(i, j, k);
                ivec3 cellCoords = cellMinCoords + cellIndices;
                loadCellSamples(cellCoords);

                cellMinMaxMinMax.rg = getCellExtremaTrilinear();
                cellMinMaxMinMax.ba = getCellExtremaTricubic();
        
                blockMinMaxMinMax.xz = min(blockMinMaxMinMax.xz, cellMinMaxMinMax.xz);
                blockMinMaxMinMax.yw = max(blockMinMaxMinMax.yw, cellMinMaxMinMax.yw);

            }}}

            return blockMinMaxMinMax;
        }

        void main()
        {
            ivec5 outputCoords = getOutputCoords();
            ivec3 blockCoords = ivec3(outputCoords.z, outputCoords.y, outputCoords.x);

            vec4 blockMinMaxMinMax = getBlockExtrema(blockCoords);
            blockMinMaxMinMax = clamp(blockMinMaxMinMax, 0.0, 1.0);
            
            setOutput(blockMinMaxMinMax);
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]): tf.Tensor
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function computeExtremaMap(interpolationMap: tf.Tensor5D, blockSize: number) : tf.Tensor
{
    const program = new GPGPUExtremaMap_v2(interpolationMap.shape, blockSize)
    return runProgram(program, [interpolationMap]) as tf.Tensor4D
}

