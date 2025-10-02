import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUPackUnsignedShort5551 implements GPGPUProgram 
{
    variableNames = ['R', 'G', 'B', 'A']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor(inputShape: number[]) 
    {
        this.outputShape = inputShape
        this.userCode = `
        uvec4 packUnsignedShort5551(uvec4 r, uvec4 g, uvec4 b, uvec4 a) 
        {
            uvec4 u = 
            (clamp(r, 0u, 31u) * 2048u) |
            (clamp(g, 0u, 31u) *   64u) |
            (clamp(b, 0u, 31u) *    2u) |
            (clamp(a, 0u,  1u) *    1u);

            return u;
        }
            
        vec4 uintHalfBitsToHalfFloat(uvec4 packed)
        {
            return vec4(
                unpackHalf2x16(packed.x).r,
                unpackHalf2x16(packed.y).r,
                unpackHalf2x16(packed.z).r,
                unpackHalf2x16(packed.w).r
            );
        }

        void main() 
        {
            uvec4 r = uvec4(getRAtOutCoords());
            uvec4 g = uvec4(getGAtOutCoords());
            uvec4 b = uvec4(getBAtOutCoords());
            uvec4 a = uvec4(getAAtOutCoords());
    
            uvec4 p = packUnsignedShort5551(r, g, b, a);
            setOutput(vec4(p));
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function packUnsignedShort5551(inputR: tf.Tensor, inputG: tf.Tensor, inputB: tf.Tensor, inputA: tf.Tensor): tf.Tensor
{
    const shape = inputR.shape
    const program = new GPGPUPackUnsignedShort5551(shape)
    return runProgram(program, [inputR, inputG, inputB, inputA])
}
