import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUToHalfFloat implements GPGPUProgram 
{
    variableNames = ['InterpolationMap']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false
    
    constructor(inputShape: number[]) 
    {
        this.outputShape = inputShape
        this.userCode = `   
        float clampToHalfRange(float values) 
        {
            return clamp(values, -65504.0, 65504.0);
        }

        // Returns the IEEE-754 half-float bit pattern, lower 16 bits of the uint.
        float toHalfFloat(float x) 
        {
            x = clampToHalfRange(x);
            uint packed = packHalf2x16(vec2(x, 0.0));
            return float(packed & 0xFFFFu); 
        }

        void main() 
        {
            float sample = getInterpolationMapAtOutCoords();
            setOutput(toHalfFloat(sample));
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
