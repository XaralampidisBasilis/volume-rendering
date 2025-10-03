import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUToHalfFloat implements GPGPUProgram 
{
    variableNames = ['InterpolationMap']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true
    
    constructor(inputShape: number[]) 
    {
        this.outputShape = inputShape
        this.userCode = `   
        vec4 clampToHalfRange(vec4 values) 
        {
            return clamp(values, -65504.0, 65504.0);
        }

        // Returns the IEEE-754 half-float bit pattern 
        vec4 toHalfFloat(vec4 v) 
        {
            v = clampToHalfRange(v);

            uint p0 = packHalf2x16(v.rg);
            uint p1 = packHalf2x16(v.ba);

            uint rBits = p0 & 0xFFFFu;
            uint gBits = p0 >> 16;
            uint bBits = p1 & 0xFFFFu;
            uint aBits = p1 >> 16;

            return vec4(rBits, gBits, bBits, aBits);
        }

        void main() 
        {
            vec4 samples = getInterpolationMapAtOutCoords();
            setOutput(toHalfFloat(samples));
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

export function toHalfFloat(inputTensor: tf.Tensor): tf.Tensor
{
    const shape = inputTensor.shape
    const program = new GPGPUToHalfFloat(shape)
    return runProgram(program, [inputTensor])
}
