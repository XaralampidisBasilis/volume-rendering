import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUOccupancyMap implements GPGPUProgram 
{
    variableNames = ['ExtremaMap']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true  

    constructor
    (
        inputShape: [number, number, number, number, number], 
        interpolationMethod: 'trilinear' | 'tricubic',
        isosurfaceValue: number
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth] 
        this.userCode = `
        const float isosurfaceValue = float(${isosurfaceValue});

        ${interpolationMethod === 'trilinear' ? `
        vec2 getExtremaMap(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 0, 0).rg; }` : `
        vec2 getExtremaMap(ivec3 coords) { return getExtremaMap(coords.z, coords.y, coords.x, 0, 0).ba; }`}

        bool getOccupancy(ivec3 coords, int innerX, int innerY) 
        {
            coords.x += innerX;
            coords.y += innerY;
            vec2 minMax = getExtremaMap(coords);
            return (isosurfaceValue >= minMax.x) && (isosurfaceValue <= minMax.y);
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords();
            ivec3 blockCoords = outputCoords.zyx;

            bool insideHeight = blockCoords.y < ${inHeight-1};
            bool insideWidth = blockCoords.x < ${inWidth-1};

            bvec4 blockOccupancies = bvec4
            (
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

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]): tf.Tensor
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function computeOccupancyMap(extremaMap: tf.Tensor5D, interpolationMethod: 'trilinear' | 'tricubic', isosurfaceValue: number): tf.Tensor
{
  const program = new GPGPUOccupancyMap(extremaMap.shape, interpolationMethod, isosurfaceValue)
  return runProgram(program, [extremaMap]) as tf.Tensor3D
}
