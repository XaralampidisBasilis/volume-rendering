import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUNormalize implements GPGPUProgram 
{
    variableNames = ['Input']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        globalMin: number, 
        globalMax: number
    ) 
    {
        this.outputShape = inputShape
        this.userCode = `
        void main() 
        {
            setOutput((getInputAtOutCoords() - ${globalMin}) / ${globalMax - globalMin});
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

export function normalize(inputTensor: tf.Tensor3D): tf.Tensor3D 
{
    const globalMin = tf.min(inputTensor).arraySync() as number
    const globalMax = tf.max(inputTensor).arraySync() as number
    const program = new GPGPUNormalize(inputTensor.shape , globalMin , globalMax)
    return runProgram(program, [inputTensor]) as tf.Tensor3D
}
