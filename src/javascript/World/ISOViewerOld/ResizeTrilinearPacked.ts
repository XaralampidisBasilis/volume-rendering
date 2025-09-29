import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class ResizeTrilinearPackedProgram implements GPGPUProgram {

    variableNames = ['A'];
    outputShape: number[];
    userCode: string;
    packedInputs = true;
    packedOutput = true;

     constructor(
        inputShape: [number, number, number, number], // [depth, height, width, channels]
        newDepth: number,
        newHeight: number,
        newWidth: number,
        alignCorners: boolean,
        halfPixelCenters: boolean
    ) {
        const [oldDepth, oldHeight, oldWidth, channels] = inputShape;
        this.outputShape = [newDepth, newHeight, newWidth, channels];

        const effectiveInSize = [
            alignCorners && newDepth  > 1 ? oldDepth  - 1 : oldDepth,
            alignCorners && newHeight > 1 ? oldHeight - 1 : oldHeight,
            alignCorners && newWidth  > 1 ? oldWidth  - 1 : oldWidth,
        ];
        const effectiveOutSize = [
            alignCorners && newDepth  > 1 ? newDepth  - 1 : newDepth,
            alignCorners && newHeight > 1 ? newHeight - 1 : newHeight,
            alignCorners && newWidth  > 1 ? newWidth  - 1 : newWidth,
        ];

        const scaleD = effectiveInSize[0] / effectiveOutSize[0];
        const scaleH = effectiveInSize[1] / effectiveOutSize[1];
        const scaleW = effectiveInSize[2] / effectiveOutSize[2];

        const sourceFracIndexExpr = halfPixelCenters
        ? `(vec3(yDHW) + vec3(0.5)) * vec3(${scaleD}, ${scaleH}, ${scaleW}) - vec3(0.5)`
        : `vec3(yDHW) * vec3(${scaleD}, ${scaleH}, ${scaleW})`;

        this.userCode = `
        const vec3 inputShapeDHW = vec3(
            ${oldDepth}.0,
            ${oldHeight}.0,
            ${oldWidth}.0
        );

        float getAValue(int d, int h, int w, int c) 
        {
            return getChannel(getA(d, h, w, c), vec2(w, c));
        }

        void main() 
        {
            . 
            ivec4 coords = getOutputCoords();
            int d = coords[0];
            int h = coords[1];
            int w = coords[2];
            int c = coords[3];

            ivec3 yDHW = ivec3(d, h, w + 1);  // for packed layout

            vec3 sourceFracIndexDHW = ${sourceFracIndexExpr};
            ivec3 sourceFloorDHW = ivec3(max(sourceFracIndexDHW, vec3(0.0)));
            ivec3 sourceCeilDHW = ivec3(min(inputShapeDHW - 1.0, ceil(sourceFracIndexDHW)));

            bool hasNextCol   = c < ${channels - 1};
            bool hasNextRow   = w < ${newWidth - 1};
            bool hasNextDepth = h < ${newHeight - 1};

            vec4 upFrontLeft = vec4(
                getAValue(sourceFloorDHW.x, sourceFloorDHW.y, sourceFloorDHW.z, c),
                hasNextCol ? getAValue(sourceFloorDHW.x, sourceFloorDHW.y, sourceFloorDHW.z, c + 1) : 0.0,
                hasNextRow ? getAValue(sourceFloorDHW.x, sourceFloorDHW.y, sourceCeilDHW.z, c) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(sourceFloorDHW.x, sourceFloorDHW.y, sourceCeilDHW.z, c + 1) : 0.0
            );

            vec4 upBackLeft = vec4(
                hasNextDepth ? getAValue(sourceCeilDHW.x, sourceFloorDHW.y, sourceFloorDHW.z, c) : 0.0,
                (hasNextDepth && hasNextCol) ? getAValue(sourceCeilDHW.x, sourceFloorDHW.y, sourceFloorDHW.z, c + 1) : 0.0,
                (hasNextDepth && hasNextRow) ? getAValue(sourceCeilDHW.x, sourceFloorDHW.y, sourceCeilDHW.z, c) : 0.0,
                (hasNextDepth && hasNextRow && hasNextCol) ? getAValue(sourceCeilDHW.x, sourceFloorDHW.y, sourceCeilDHW.z, c + 1) : 0.0
            );

            vec4 downFrontLeft = vec4(
                getAValue(sourceFloorDHW.x, sourceCeilDHW.y, sourceFloorDHW.z, c),
                hasNextCol ? getAValue(sourceFloorDHW.x, sourceCeilDHW.y, sourceFloorDHW.z, c + 1) : 0.0,
                hasNextRow ? getAValue(sourceFloorDHW.x, sourceCeilDHW.y, sourceCeilDHW.z, c) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(sourceFloorDHW.x, sourceCeilDHW.y, sourceCeilDHW.z, c + 1) : 0.0
            );

            vec4 downBackLeft = vec4(
                hasNextDepth ? getAValue(sourceCeilDHW.x, sourceCeilDHW.y, sourceFloorDHW.z, c) : 0.0,
                (hasNextDepth && hasNextCol) ? getAValue(sourceCeilDHW.x, sourceCeilDHW.y, sourceFloorDHW.z, c + 1) : 0.0,
                (hasNextDepth && hasNextRow) ? getAValue(sourceCeilDHW.x, sourceCeilDHW.y, sourceCeilDHW.z, c) : 0.0,
                (hasNextDepth && hasNextRow && hasNextCol) ? getAValue(sourceCeilDHW.x, sourceCeilDHW.y, sourceCeilDHW.z, c + 1) : 0.0
            );

            vec3 fracDHW = sourceFracIndexDHW - vec3(sourceFloorDHW);

            vec4 frontMix = mix(upFrontLeft, downFrontLeft, fracDHW.y);
            vec4 backMix = mix(upBackLeft, downBackLeft, fracDHW.y);
            vec4 mixed = mix(frontMix, backMix, fracDHW.x);

            vec4 finalColor = mix(mixed.xyzw, mixed.zwxy, fracDHW.z);

            setOutput(finalColor);
        }
        `;
   }
}

export function resizeTrilinearPacked(
    input: tf.Tensor4D,
    newDepth: number,
    newHeight: number,
    newWidth: number,
    alignCorners = false,
    halfPixelCenters = false
): tf.Tensor4D 
{
  const backend = tf.backend() as MathBackendWebGL;
  const program = new ResizeTrilinearPackedProgram(
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


export class ResizeBilinearPackedProgram 
{
    constructor(
        inputShape, 
        newHeight, 
        newWidth, 
        alignCorners, 
        halfPixelCenters
    ) {

        this.variableNames = ['A'];
        this.packedInputs = true;
        this.packedOutput = true;
        this.outputShape = [];

        const [batch, oldHeight, oldWidth, depth] = inputShape;
        this.outputShape = [batch, newHeight, newWidth, depth];

        const effectiveInSize = [
            (alignCorners && newHeight > 1) ? oldHeight - 1 : oldHeight,
            (alignCorners && newWidth > 1) ? oldWidth - 1 : oldWidth
        ];
        const effectiveOutSize = [
            (alignCorners && newHeight > 1) ? newHeight - 1 : newHeight,
            (alignCorners && newWidth > 1) ? newWidth - 1 : newWidth
        ];

        let sourceFracIndexRC;
        if (halfPixelCenters) {
            sourceFracIndexRC = `(vec3(yRC) + vec3(0.5)) * effectiveInputOverOutputRatioRC - vec3(0.5)`;
        }
        else {
            sourceFracIndexRC = `vec3(yRC) * effectiveInputOverOutputRatioRC`;
        }

        this.userCode = `

        const vec3 effectiveInputOverOutputRatioRC = vec3(
            ${effectiveInSize[0] / effectiveOutSize[0]},
            ${effectiveInSize[1] / effectiveOutSize[1]},
            ${effectiveInSize[1] / effectiveOutSize[1]}
        );

        const vec3 inputShapeRC = vec3(
            ${oldHeight}.0, 
            ${oldWidth}.0,
            ${oldWidth}.0
        );


        float getAValue(int b, int r, int c, int d) 
        {
            return getChannel(getA(b, r, c, d), vec2(c, d));
        }

        void main() 
        {
            ivec4 coords = getOutputCoords();
            int b = coords[0];
            int d = coords[3];

            // Calculate values for next column in yRC.z.
            ivec3 yRC = coords.yzz + ivec3(0, 0, 1);

            // Fractional source index.
            vec3 sourceFracIndexRC = ${sourceFracIndexRC};

            // Compute the four integer indices.
            ivec3 sourceFloorRC = ivec3(max(sourceFracIndexRC, vec3(0.0)));
            ivec3 sourceCeilRC = ivec3(min(inputShapeRC - 1.0, ceil(sourceFracIndexRC)));

            // Should we calculate next column and row elements in 2x2 packed cell.
            bool hasNextCol = d < ${depth - 1};
            bool hasNextRow = coords.z < ${newWidth - 1};

            // In parallel, construct four corners for all four components in
            // packed 2x2 cell.

            vec4 topLeft = vec4
            (
                getAValue(b, sourceFloorRC.x, sourceFloorRC.y, d),
                hasNextCol ? getAValue(b, sourceFloorRC.x, sourceFloorRC.y, d + 1): 0.0,
                hasNextRow ? getAValue(b, sourceFloorRC.x, sourceFloorRC.z, d) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(b, sourceFloorRC.x, sourceFloorRC.z, d + 1) : 0.0
            );


            vec4 bottomLeft = vec4
            (
                getAValue(b, sourceCeilRC.x, sourceFloorRC.y, d),
                hasNextCol ? getAValue(b, sourceCeilRC.x, sourceFloorRC.y, d + 1) : 0.0,
                hasNextRow ? getAValue(b, sourceCeilRC.x, sourceFloorRC.z, d) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(b, sourceCeilRC.x, sourceFloorRC.z, d + 1) : 0.0
            );


            vec4 topRight = vec4
            (
                getAValue(b, sourceFloorRC.x, sourceCeilRC.y, d),
                hasNextCol ? getAValue(b, sourceFloorRC.x, sourceCeilRC.y, d + 1) : 0.0,
                hasNextRow ? getAValue(b, sourceFloorRC.x, sourceCeilRC.z, d) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(b, sourceFloorRC.x, sourceCeilRC.z, d + 1) : 0.0
            );


            vec4 bottomRight = vec4
            (
                getAValue(b, sourceCeilRC.x, sourceCeilRC.y, d),
                hasNextCol ? getAValue(b, sourceCeilRC.x, sourceCeilRC.y, d + 1) : 0.0,
                hasNextRow ? getAValue(b, sourceCeilRC.x, sourceCeilRC.z, d) : 0.0,
                (hasNextRow && hasNextCol) ? getAValue(b, sourceCeilRC.x, sourceCeilRC.z, d + 1) : 0.0
            );


            vec3 fracRC = sourceFracIndexRC - vec3(sourceFloorRC);

            vec4 top = mix(topLeft, topRight, fracRC.yyzz);
            vec4 bottom = mix(bottomLeft, bottomRight, fracRC.yyzz);
            vec4 newValue = mix(top, bottom, fracRC.x);

            setOutput(newValue);
        }
        `;
    }
}