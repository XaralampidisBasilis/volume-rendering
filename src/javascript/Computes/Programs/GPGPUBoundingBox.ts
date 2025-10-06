import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class GPGPUOccupiedCoords implements GPGPUProgram 
{
    variableNames = ['InputOccupancy']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number],
        inputMode: 'min' | 'max'
    ) 
    {
        const boundaryCoord = inputMode === 'min' ? inputShape[0]-1 : 0
        this.outputShape = inputShape
        this.userCode = `
        void main() 
        {
            float inOccupancy = getInputOccupancyAtOutCoords();
            int outCoord = (inOccupancy > 0.5) ? getOutputCoords() : ${boundaryCoord};
            setOutput(float(outCoord));
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

export function computeBoundingBox(occupancyMap: tf.Tensor3D): Object
{   
    const zOccupancyMap = occupancyMap.max([1, 2]);
    const xyOccupancyMap = occupancyMap.max(0);
    const yOccupancyMap = xyOccupancyMap.max(1);
    const xOccupancyMap = xyOccupancyMap.max(0);
    xyOccupancyMap.dispose()

    const xMinProgram = new GPGPUOccupiedCoords(xOccupancyMap.shape as [number], 'min')
    const xMaxProgram = new GPGPUOccupiedCoords(xOccupancyMap.shape as [number], 'max')
    const yMinProgram = new GPGPUOccupiedCoords(yOccupancyMap.shape as [number], 'min')
    const yMaxProgram = new GPGPUOccupiedCoords(yOccupancyMap.shape as [number], 'max')
    const zMinProgram = new GPGPUOccupiedCoords(zOccupancyMap.shape as [number], 'min')
    const zMaxProgram = new GPGPUOccupiedCoords(zOccupancyMap.shape as [number], 'max')
    
    const xMinCoords = runProgram(xMinProgram, [xOccupancyMap])
    const xMaxCoords = runProgram(xMaxProgram, [xOccupancyMap]); xOccupancyMap.dispose() 
    const yMinCoords = runProgram(yMinProgram, [yOccupancyMap])
    const yMaxCoords = runProgram(yMaxProgram, [yOccupancyMap]); yOccupancyMap.dispose() 
    const zMinCoords = runProgram(zMinProgram, [zOccupancyMap])
    const zMaxCoords = runProgram(zMaxProgram, [zOccupancyMap]); zOccupancyMap.dispose() 

    const xMinCoord = xMinCoords.min(); xMinCoords.dispose()
    const xMaxCoord = xMaxCoords.max(); xMaxCoords.dispose()
    const yMinCoord = yMinCoords.min(); yMinCoords.dispose()
    const yMaxCoord = yMaxCoords.max(); yMaxCoords.dispose()
    const zMinCoord = zMinCoords.min(); zMinCoords.dispose()
    const zMaxCoord = zMaxCoords.max(); zMaxCoords.dispose()

    const minCoords = [
        xMinCoord.arraySync(),
        yMinCoord.arraySync(),
        zMinCoord.arraySync(),
    ]
    tf.dispose([xMinCoord, yMinCoord, zMinCoord])

    const maxCoords = [
        xMaxCoord.arraySync(),
        yMaxCoord.arraySync(),
        zMaxCoord.arraySync(),
    ]
    tf.dispose([xMaxCoord, yMaxCoord, zMaxCoord])
        
    return { minCoords, maxCoords }
}