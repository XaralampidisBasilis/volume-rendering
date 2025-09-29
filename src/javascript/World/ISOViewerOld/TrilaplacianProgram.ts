import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

export class TrilaplacianProgram implements GPGPUProgram 
{
    variableNames = ['A'];
    outputShape: number[];
    userCode: string;
    packedInputs = false;
    packedOutput = false;

    constructor(inputShape: [number, number, number, number]) 
    {
        const [inDepth, inHeight, inWidth, _] = inputShape;
        this.outputShape = [inDepth, inHeight, inWidth, 4];
        this.userCode = `
        void main() 
        {
            ivec4 outputCoords = getOutputCoords();

            int voxelZ = outputCoords[0];
            int voxelY = outputCoords[1];
            int voxelX = outputCoords[2];

            float F = getA(voxelZ, voxelY, voxelX, 0);

            int outputChannel = outputCoords[3];

            if (outputChannel == 3)
            {
                setOutput(F);
            }

            if (outputChannel == 2)
            {
                ivec2 frontBack = clamp(voxelZ + ivec2(-1, 1), 0, ${inDepth - 1});

                float Fzz = getA(frontBack.x, voxelY, voxelX, 0) + 
                            getA(frontBack.y, voxelY, voxelX, 0) - F * 2.0;

                setOutput(Fzz);
            }

            if (outputChannel == 1)
            {
                ivec2 topBottom = clamp(voxelY + ivec2(-1, 1), 0, ${inHeight - 1});

                float Fyy = getA(voxelZ, topBottom.x, voxelX, 0) + 
                            getA(voxelZ, topBottom.y, voxelX, 0) - F * 2.0;

                setOutput(Fyy);
            }

            if (outputChannel == 0)
            {
                ivec2 leftRight = clamp(voxelX + ivec2(-1, 1), 0, ${inWidth - 1});

                float Fxx = getA(voxelZ, voxelY, leftRight.x, 0) + 
                            getA(voxelZ, voxelY, leftRight.y, 0) - F * 2.0;

                setOutput(Fxx);
            }
        }
        `;
    }
}


export function trilaplacianProgram(input: tf.Tensor4D): tf.Tensor4D 
{
  const backend = tf.backend() as MathBackendWebGL
  const program = new TrilaplacianProgram(input.shape)
  const output = backend.compileAndRun(program, [input])
  return tf.engine().makeTensorFromTensorInfo(output) as tf.Tensor4D
}