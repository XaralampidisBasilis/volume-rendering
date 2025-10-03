import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUPackUnsignedShort5551 implements GPGPUProgram 
{
    variableNames = ['R', 'G', 'B', 'A']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor(inputShape: number[]) 
    {
        this.outputShape = inputShape
        this.userCode = `
        uint packUnsignedShort5551(uint x, uint y, uint z, uint o)
        {
            uint u = 
            (clamp(x, 0u, 31u) << 11) |
            (clamp(y, 0u, 31u) <<  6) |
            (clamp(z, 0u, 31u) <<  1) |
            (clamp(o, 0u, 31u) <<  0);

            return u;
        }

        float uintHalfBitsToHalfFloat(uint p)
        {
            return unpackHalf2x16(p).r;
        }

        void main() 
        {
            uint r = uint(getRAtOutCoords());
            uint g = uint(getGAtOutCoords());
            uint b = uint(getBAtOutCoords());
            uint a = uint(getAAtOutCoords());

            uint p = packUnsignedShort5551(r, g, b, a);
            setOutput(float(p));
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function packUnsignedShort5551(inputR: tf.Tensor, inputG: tf.Tensor, inputB: tf.Tensor, inputA: tf.Tensor): tf.Tensor
{
    const shape = inputR.shape
    const program = new GPGPUPackUnsignedShort5551(shape)
    return runProgram(program, [inputR, inputG, inputB, inputA])
}
