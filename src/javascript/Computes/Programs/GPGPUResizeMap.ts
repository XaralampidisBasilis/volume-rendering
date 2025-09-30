import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class GPGPUResizeMap implements GPGPUProgram 
{
    variableNames = ['Input']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        outputShape: [number, number, number],
        alignCorners: boolean,
        halfPixelCenters: boolean
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const [newDepth, newHeight, newWidth] = outputShape
        this.outputShape = outputShape

        const effectiveInSize = [
            alignCorners && newDepth  > 1 ? inDepth  - 1 : inDepth,
            alignCorners && newHeight > 1 ? inHeight - 1 : inHeight,
            alignCorners && newWidth  > 1 ? inWidth  - 1 : inWidth
        ];
        const effectiveOutSize = [
            alignCorners && newDepth  > 1 ? newDepth  - 1 : newDepth,
            alignCorners && newHeight > 1 ? newHeight - 1 : newHeight,
            alignCorners && newWidth  > 1 ? newWidth  - 1 : newWidth
        ];

        const scaleFactors = effectiveInSize.map((inSize, i) => inSize / effectiveOutSize[i])

        const sourceFracIndex = halfPixelCenters
        ? `(vec3(coords) + vec3(0.5)) * scaleFactors - vec3(0.5)`
        : `vec3(coords) * scaleFactors`

        this.userCode = `
        const vec3 scaleFactors = vec3(${scaleFactors[0]}, ${scaleFactors[1]}, ${scaleFactors[2]});
        const vec3 inputShape = vec3(${inDepth}, ${inHeight}, ${inWidth});

        void main() 
        {
            ivec3 coords = getOutputCoords();
            vec3 sourceFracIndex = ${sourceFracIndex};

            vec3 floorIndex = clamp(floor(sourceFracIndex), vec3(0.0), inputShape - 1.0);
            vec3 ceilIndex  = clamp(ceil(sourceFracIndex),  vec3(0.0), inputShape - 1.0);
            vec3 frac = sourceFracIndex - floorIndex;

            float c000 = getInput(int(floorIndex.x), int(floorIndex.y), int(floorIndex.z));
            float c001 = getInput(int(floorIndex.x), int(floorIndex.y), int(ceilIndex.z));
            float c010 = getInput(int(floorIndex.x), int(ceilIndex.y),  int(floorIndex.z));
            float c011 = getInput(int(floorIndex.x), int(ceilIndex.y),  int(ceilIndex.z));
            float c100 = getInput(int(ceilIndex.x),  int(floorIndex.y), int(floorIndex.z));
            float c101 = getInput(int(ceilIndex.x),  int(floorIndex.y), int(ceilIndex.z));
            float c110 = getInput(int(ceilIndex.x),  int(ceilIndex.y),  int(floorIndex.z));
            float c111 = getInput(int(ceilIndex.x),  int(ceilIndex.y),  int(ceilIndex.z));

            float c00 = mix(c000, c001, frac.z);
            float c01 = mix(c010, c011, frac.z);
            float c10 = mix(c100, c101, frac.z);
            float c11 = mix(c110, c111, frac.z);

            float c0 = mix(c00, c01, frac.y);
            float c1 = mix(c10, c11, frac.y);

            float value = mix(c0, c1, frac.x);

            setOutput(value);
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

export function computeResizedMap
(
    inputTensor: tf.Tensor3D, 
    outputShape: [number, number, number], 
    alignCorners = false, 
    halfPixelCenters = false
): tf.Tensor 
{
    const compareArrays = (a: number[], b: number[]) => JSON.stringify(a) === JSON.stringify(b);
    if (compareArrays(inputTensor.shape, outputShape)) return inputTensor

    const program = new GPGPUResizeMap(inputTensor.shape, outputShape, alignCorners, halfPixelCenters);
    return runProgram(program, [inputTensor]) as tf.Tensor3D;
}