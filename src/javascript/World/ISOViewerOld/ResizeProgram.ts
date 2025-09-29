import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class ResizeProgram implements GPGPUProgram 
{
    variableNames = ['A'];
    outputShape: number[];
    userCode: string;

    constructor(
        inputShape: [number, number, number, number], // [depth, height, width, channels]
        newDepth: number,
        newHeight: number,
        newWidth: number,
        alignCorners: boolean,
        halfPixelCenters: boolean
    ) {
        const [inDepth, inHeight, inWidth, channels] = inputShape;
        this.outputShape = [newDepth, newHeight, newWidth, channels];

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

        const scaleFactors = effectiveInSize.map((inSize, i) => inSize / effectiveOutSize[i]);

        const sourceFracIndex = halfPixelCenters
        ? `(vec3(dhw) + vec3(0.5)) * scaleFactors - vec3(0.5)`
        : `vec3(dhw) * scaleFactors`;

        this.userCode = `
        const vec3 scaleFactors = vec3(${scaleFactors[0]}, ${scaleFactors[1]}, ${scaleFactors[2]});
        const vec3 inputShape = vec3(${inDepth}, ${inHeight}, ${inWidth});

        void main() 
        {
            ivec4 coords = getOutputCoords();
            int d = coords[0];
            int h = coords[1];
            int w = coords[2];
            int c = coords[3];

            ivec3 dhw = ivec3(d, h, w);
            vec3 sourceFracIndex = ${sourceFracIndex};

            vec3 floorIndex = clamp(floor(sourceFracIndex), vec3(0.0), inputShape - 1.0);
            vec3 ceilIndex  = clamp(ceil(sourceFracIndex),  vec3(0.0), inputShape - 1.0);
            vec3 frac = sourceFracIndex - floorIndex;

            float c000 = getA(int(floorIndex.x), int(floorIndex.y), int(floorIndex.z), c);
            float c001 = getA(int(floorIndex.x), int(floorIndex.y), int(ceilIndex.z),  c);
            float c010 = getA(int(floorIndex.x), int(ceilIndex.y),  int(floorIndex.z), c);
            float c011 = getA(int(floorIndex.x), int(ceilIndex.y),  int(ceilIndex.z),  c);
            float c100 = getA(int(ceilIndex.x),  int(floorIndex.y), int(floorIndex.z), c);
            float c101 = getA(int(ceilIndex.x),  int(floorIndex.y), int(ceilIndex.z),  c);
            float c110 = getA(int(ceilIndex.x),  int(ceilIndex.y),  int(floorIndex.z), c);
            float c111 = getA(int(ceilIndex.x),  int(ceilIndex.y),  int(ceilIndex.z),  c);

            float c00 = mix(c000, c001, frac.z);
            float c01 = mix(c010, c011, frac.z);
            float c10 = mix(c100, c101, frac.z);
            float c11 = mix(c110, c111, frac.z);

            float c0 = mix(c00, c01, frac.y);
            float c1 = mix(c10, c11, frac.y);

            float value = mix(c0, c1, frac.x);

            setOutput(value);
        }
        `;
    }
}


export function resizeProgram(
  input: tf.Tensor4D,
  newDepth: number,
  newHeight: number,
  newWidth: number,
  alignCorners = false,
  halfPixelCenters = false
): tf.Tensor4D 
{
  const backend = tf.backend() as MathBackendWebGL;
  const program = new ResizeProgram(
    input.shape as [number, number, number, number],
    newDepth,
    newHeight,
    newWidth,
    alignCorners,
    halfPixelCenters
  );

  const output = backend.compileAndRun(program, [input]);
  return tf.engine().makeTensorFromTensorInfo(output) as tf.Tensor4D;
}