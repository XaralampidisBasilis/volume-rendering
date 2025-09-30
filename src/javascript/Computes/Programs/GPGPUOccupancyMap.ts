import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUOccupancyMap implements GPGPUProgram 
{
    variableNames = ['InputExtrema']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number, number], 
        interpolationMethod: 'trilinear' | 'tricubic',
        isosurfaceValue: number
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        const float isosurfaceValue = float(${isosurfaceValue});

        ${interpolationMethod === 'trilinear' ? `
        float getInputMinima(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 0); }` : `
        float getInputMinima(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 2); }`}

        ${interpolationMethod === 'trilinear' ? `
        float getInputMaxima(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 1); }` : `
        float getInputMaxima(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 3); }`}

        void main() 
        {
            ivec3 inputCoords = getOutputCoords().zyx;

            float minValue = getInputMinima(inputCoords);
            float maxValue = getInputMaxima(inputCoords);

            bool occupied = (isosurfaceValue >= minValue) && (isosurfaceValue <= maxValue);

            setOutput(occupied ? 1.0 : 0.0);
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

export function computeOccupancyMap(extremaMap: tf.Tensor4D, interpolationMethod: 'trilinear' | 'tricubic', isosurfaceValue: number): tf.Tensor
{
  const program = new GPGPUOccupancyMap(extremaMap.shape, interpolationMethod, isosurfaceValue)
  return runProgram(program, [extremaMap]) as tf.Tensor3D
}
