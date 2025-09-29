import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUExtremaMap implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number, number], 
        interpolationMethod: 'trilinear' | 'tricubic',
        inputStride: number
    ) 
    {
        const ceilDiv = (x: number) => Math.ceil((x + 1) / inputStride)
        const [inDepth, inHeight, inWidth, , ] = inputShape
        const [outDepth, outHeight, outWidth] = [inDepth, inHeight, inWidth].map(ceilDiv)
        this.outputShape = [outDepth, outHeight, outWidth, 2, 2]     

        const getCellExtremaTrilinear = `
        vec2 getCellExtrema(ivec3 cellCoords)
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
        `
        const getCellExtremaTricubic = `
        const mat2x4 Elevations = mat2x4(
            1.0, 2.0/3.0, 1.0/3.0, 0.0,   
            0.0, 1.0/3.0, 2.0/3.0, 1.0
        );

        const mat2x4 Contributions = mat2x4(
            0.0, -0.25,  0.0,  0.0,  
            0.0,  0.0, -0.25,  0.0
        );

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
                vec4  M = vec4(Mx, My, Mz, 1.0);

                float Wx = Elevations[p][u];
                float Wy = Elevations[q][v];
                float Wz = Elevations[r][w];
                float W = Wx * Wy * Wz;

                bernsteinCoefficient += dot(V, M) * W;

            }}} 

            return bernsteinCoefficient;
        }

        vec2 getCellExtrema(ivec3 cellCoords)
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
        `
        this.userCode = `

        const ivec3 voxelMinCoords = ivec3(0);
        const ivec3 voxelMaxCoords = ivec3(${inWidth-1}, ${inHeight-1}, ${inDepth-1});

        vec4 getVoxelSample(ivec3 voxelCoords)
        {
            voxelCoords = clamp(voxelCoords, voxelMinCoords, voxelMaxCoords);
            return vec4(
                getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0), // Fxx
                getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 1), // Fyy
                getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 2), // Fzz
                getA(voxelCoords.z, voxelCoords.y, voxelCoords.x, 3)  // F
            );
        }
        }

        ${interpolationMethod === 'trilinear' 
        ? getCellExtremaTrilinear 
        : getCellExtremaTricubic}

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
            ivec4 outputCoords = getOutputCoords();
            ivec3 blockCoords = outputCoords.zyx;
            
            vec2 blockMinMax = getBlockExtrema(blockCoords);
            blockMinMax = clamp(blockMinMax, 0.0, 1.0);

            setOutput((outputCoords.w == 0) ? blockMinMax.x : blockMinMax.y);
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

export function getExtremaMap(interpolationMap: tf.Tensor4D, interpolationMethod: 'trilinear' | 'tricubic', inputStride: number) : tf.Tensor
{
    const program = new GPGPUExtremaMap(interpolationMap.shape, interpolationMethod, inputStride)
    return runProgram(program, [interpolationMap]) as tf.Tensor4D
}