import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class OccupancyPackedProgram implements GPGPUProgram 
{
    variableNames = ['ExtremaPacked']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = false

    constructor(inputShape: [number, number, number, number, number], inputValue: number) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        void main() 
        {
            ivec3 outputCoords = getOutputCoords();
            int blockZ = outputCoords.x;
            int blockY = outputCoords.y;
            int blockX = outputCoords.z;

            vec4 blockMinMaxValue = getExtremaPacked(blockZ, blockY, blockX, 0, 0);
            bool blockOccupied = 
                ${inputValue} >= blockMinMaxValue.x && 
                ${inputValue} <= blockMinMaxValue.y;

            setOutput(blockOccupied ? 255.0 : 0.0);
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor3D 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor3D
}

export function occupancyPackedProgram(inputTensor: tf.Tensor5D, inputValue: number): tf.Tensor3D 
{
  const program = new OccupancyPackedProgram(inputTensor.shape, inputValue)
  return runProgram(program, [inputTensor]) as tf.Tensor3D
}