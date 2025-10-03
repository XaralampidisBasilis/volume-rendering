import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class GPGPUResizeTrilinear implements GPGPUProgram 
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
        const [outDepth, outHeight, outWidth] = outputShape
        this.outputShape = outputShape

        const effectiveInSize = [
            alignCorners && outDepth  > 1 ? inDepth  - 1 : inDepth,
            alignCorners && outHeight > 1 ? inHeight - 1 : inHeight,
            alignCorners && outWidth  > 1 ? inWidth  - 1 : inWidth
        ];
        const effectiveOutSize = [
            alignCorners && outDepth  > 1 ? outDepth  - 1 : outDepth,
            alignCorners && outHeight > 1 ? outHeight - 1 : outHeight,
            alignCorners && outWidth  > 1 ? outWidth  - 1 : outWidth
        ];

        const scaleFactors = effectiveInSize.map((inSize, i) => inSize / effectiveOutSize[i])
        const offsetFactor = halfPixelCenters ? 0.5 : 0.0;

        this.userCode = `
        const vec3 scaleFactors = vec3(${scaleFactors[0]}, ${scaleFactors[1]}, ${scaleFactors[2]});
        const ivec3 inputShape = ivec3(${inDepth}, ${inHeight}, ${inWidth});

        void main() 
        {
            ivec3 coords = getOutputCoords();
            vec3 sourceFracIndex = (vec3(coords) + ${offsetFactor}) * scaleFactors - ${offsetFactor};
            vec3 sourceFrac = fract(sourceFracIndex);

            ivec3 floorIndex = clamp(ivec3(floor(sourceFracIndex)), ivec3(0), inputShape - 1);
            ivec3 ceilIndex  = clamp(ivec3(ceil(sourceFracIndex)),  ivec3(0), inputShape - 1);

            float c000 = getInput(floorIndex.x, floorIndex.y, floorIndex.z);
            float c001 = getInput(floorIndex.x, floorIndex.y, ceilIndex.z);
            float c010 = getInput(floorIndex.x, ceilIndex.y,  floorIndex.z);
            float c011 = getInput(floorIndex.x, ceilIndex.y,  ceilIndex.z);
            float c100 = getInput(ceilIndex.x,  floorIndex.y, floorIndex.z);
            float c101 = getInput(ceilIndex.x,  floorIndex.y, ceilIndex.z);
            float c110 = getInput(ceilIndex.x,  ceilIndex.y,  floorIndex.z);
            float c111 = getInput(ceilIndex.x,  ceilIndex.y,  ceilIndex.z);

            float c00 = mix(c000, c001, sourceFrac.z);
            float c01 = mix(c010, c011, sourceFrac.z);
            float c10 = mix(c100, c101, sourceFrac.z);
            float c11 = mix(c110, c111, sourceFrac.z);

            float c0 = mix(c00, c01, sourceFrac.y);
            float c1 = mix(c10, c11, sourceFrac.y);

            float value = mix(c0, c1, sourceFrac.x);

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

function compareArrays(a: number[], b: number[]): boolean
{
    return JSON.stringify(a) === JSON.stringify(b)
}

export function resizeTrilinear
(
    inputTensor: tf.Tensor3D, 
    outputShape: [number, number, number], 
    alignCorners = false, 
    halfPixelCenters = true
): tf.Tensor 
{
    if (compareArrays(inputTensor.shape, outputShape)) return inputTensor
    const program = new GPGPUResizeTrilinear(inputTensor.shape, outputShape, alignCorners, halfPixelCenters);
    return runProgram(program, [inputTensor]) as tf.Tensor3D;
}