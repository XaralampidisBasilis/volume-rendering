import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class TrilaplacianPackedProgram implements GPGPUProgram 
{
    variableNames = ['A']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = true

    constructor(inputShape: [number, number, number, number]) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth, 2, 2]
        this.userCode = `   
        void main()
        {
            ivec5 outputCoords = getOutputCoords();

            int voxelX = outputCoords.z;
            int voxelY = outputCoords.y;
            int voxelZ = outputCoords.x;

            ivec2 leftRight = clamp(voxelX + ivec2(-1, 1), 0, ${inWidth - 1});
            ivec2 topBottom = clamp(voxelY + ivec2(-1, 1), 0, ${inHeight - 1});
            ivec2 frontBack = clamp(voxelZ + ivec2(-1, 1), 0, ${inDepth - 1});

            float F = getA(voxelZ, voxelY, voxelX, 0);

            float Fxx = getA(voxelZ, voxelY, leftRight.x, 0) + 
                        getA(voxelZ, voxelY, leftRight.y, 0) - F * 2.0;

            float Fyy = getA(voxelZ, topBottom.x, voxelX, 0) + 
                        getA(voxelZ, topBottom.y, voxelX, 0) - F * 2.0;

            float Fzz = getA(frontBack.x, voxelY, voxelX, 0) + 
                        getA(frontBack.y, voxelY, voxelX, 0) - F * 2.0;
         
            setOutput(vec4(Fxx, Fyy, Fzz, F));        
        }
        `;
    }
}

class GPGPUInterpolationMapToHalfFloat implements GPGPUProgram 
{
    variableNames = ['InterpolationMap']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = false

    constructor(inputShape: [number, number, number, number, number]) 
    {
        const [inDepth, inHeight, inWidth, , ] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth, 2]
        this.userCode = `   
        vec4 clampToHalfRange(vec4 values) 
        {
            return clamp(values, -65504.0, 65504.0);
        }

        void main() 
        {
            ivec4 outputCoords = getOutputCoords();
            ivec3 voxelCoords = outputCoords.zyx;
            int lane = outputCoords.w;

            vec4 voxelSamples = getInterpolationMap(voxelCoords.z, voxelCoords.y, voxelCoords.x, 0, 0);
            voxelSamples = clampToHalfRange(voxelSamples) ;

            uint packed = (lane == 0)
            ? packHalf2x16(vec2(voxelSamples.r, voxelSamples.g))  
            : packHalf2x16(vec2(voxelSamples.b, voxelSamples.a)); 

            setOutput(uintBitsToFloat(packed));
        }
    `
    }
}

export function trilaplacianPackedProgram(inputTensor: tf.Tensor4D): tf.Tensor4D 
{
    const inputShape = inputTensor.shape
    const backend = tf.backend() as MathBackendWebGL
    const program = new TrilaplacianPackedProgram(inputShape)
    const output = backend.compileAndRun(program, [inputTensor])

    return tf.engine().makeTensorFromTensorInfo(output) as tf.Tensor4D
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]): tf.Tensor
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function computeInterpolationMapToHalfFloat(InterpolationMap: tf.Tensor5D): tf.Tensor 
{
  const program = new GPGPUInterpolationMapToHalfFloat(InterpolationMap.shape)
  return runProgram(program, [InterpolationMap]) as tf.Tensor4D
}
