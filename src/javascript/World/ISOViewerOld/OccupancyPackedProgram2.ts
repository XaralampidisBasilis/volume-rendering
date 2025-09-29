import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class OccupancyPackedProgram implements GPGPUProgram 
{
    variableNames = ['InputExtrema']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true  

    constructor
    (
        inputShape: [number, number, number, number, number], 
        inputValue: number
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth] // Logical output shape stays the same; packing is a storage optimization.
        this.userCode = `
        const float inputValue = float(${inputValue});

        vec2 getInputExtrema(ivec3 coords) { return getInputExtrema(coords.z, coords.y, coords.x, 0, 0).rg; }

        bool getOccupancy(ivec3 coords, int innerX, int innerY) 
        {
            coords.x += innerX;
            coords.y += innerY;
            vec2 minMax = getInputExtrema(coords);
            return (inputValue >= minMax.x) && (inputValue <= minMax.y);
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords();
            ivec3 blockCoords = outputCoords.zyx;

            bool insideHeight = blockCoords.y < ${inHeight-1};
            bool insideWidth = blockCoords.x < ${inWidth-1};

            bvec4 blockOccupancies = bvec4(
                getOccupancy(blockCoords, 0, 0),
                (insideWidth) ? getOccupancy(blockCoords, 1, 0) : false,
                (insideHeight) ? getOccupancy(blockCoords, 0, 1) : false,
                (insideWidth && insideHeight) ? getOccupancy(blockCoords, 1, 1) : false
            );

            setOutput(vec4(blockOccupancies));
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]): tf.Tensor3D 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor3D
}

export function occupancyPackedProgram2(inputTensor: tf.Tensor5D, inputValue: number): tf.Tensor3D 
{
  const program = new OccupancyPackedProgram(inputTensor.shape as any, inputValue)
  return runProgram(program, [inputTensor]) as tf.Tensor3D
}
