import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class OccupancyProgram implements GPGPUProgram 
{
    variableNames = ['Extrema']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor(inputShape: [number, number, number, number], inputValue: number) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        void main() 
        {
            ivec3 outputCoords = getOutputCoords();
            ivec3 blockCoords = outputCoords.zyx;

            float minValue = getExtrema(blockCoords.z, blockCoords.y, blockCoords.x, 0);
            float maxValue = getExtrema(blockCoords.z, blockCoords.y, blockCoords.x, 1);
            bool blockOccupied = ${inputValue} >= minValue && ${inputValue} <= maxValue;

            setOutput(blockOccupied ? 1.0 : 0.0);
        }
        `;
    }
}

export function occupancyProgram(input: tf.Tensor4D, inputThreshold: number): tf.Tensor4D 
{
  const backend = tf.backend() as MathBackendWebGL;
  const program = new OccupancyProgram(input.shape as [number, number, number, number], inputThreshold);
  const output = backend.compileAndRun(program, [input]);
  return tf.engine().makeTensorFromTensorInfo(output) as tf.Tensor4D;
}