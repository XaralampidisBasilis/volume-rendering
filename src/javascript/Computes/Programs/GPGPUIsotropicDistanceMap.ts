import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class IsotropicChebyshevDistancePass implements GPGPUProgram 
{
    variableNames = ['InputVariable']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        inputVariable: 'occupancy' | 'distance',
        inputAxis: 'x' | 'y' | 'z',     
        maxDistance: number,
    ) 
    {
        const inIndex = ['z', 'y', 'x'].findIndex(x => x === inputAxis)
        const [inDepth, inHeight, inWidth] = inputShape
        const inDimension = inputShape[inIndex]
        const maxSteps = Math.min(maxDistance, inDimension-1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        float getInputVariable(ivec3 coords) { return getInputVariable(coords.z, coords.y, coords.x); }

        ${inputVariable == 'occupancy' ? `
        int getInputDistance(ivec3 coords) { return int(getInputVariable(coords) < 0.5) * ${maxDistance}; }` : `
        int getInputDistance(ivec3 coords) { return int(getInputVariable(coords)); }` }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;
            
            int candidateDistance;
            int inputDistance = getInputDistance(outputCoords);
            int outputDistance = inputDistance;

            if (outputDistance <= 1) 
            {
                setOutput(float(outputDistance));
                return;
            }

            for (int stepDistance = 1; stepDistance <= ${maxSteps}; stepDistance++) 
            {
                inputCoords.${inputAxis} = outputCoords.${inputAxis} - stepDistance;
                if (inputCoords.${inputAxis} >= 0) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, stepDistance);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= stepDistance) 
                    {
                        break;
                    }
                }

                inputCoords.${inputAxis} = outputCoords.${inputAxis} + stepDistance;
                if (inputCoords.${inputAxis} <= ${inDimension-1}) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, stepDistance);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= stepDistance) 
                    {
                        break;
                    }
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}

class FirstIsotropicChebyshevDistancePassX implements GPGPUProgram 
{
    variableNames = ['InputOccupancy']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const maxSteps = Math.min(maxDistance, inWidth-1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        bool getInputOccupancy(ivec3 coords) 
        { 
            return (getInputOccupancy(coords.z, coords.y, coords.x) > 0.5); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            int outputDistance = ${maxDistance};

            if (getInputOccupancy(inputCoords)) 
            {
                setOutput(0.0);
                return;
            }

            for (int xStep = 1; xStep <= ${maxSteps}; xStep++) 
            {
                inputCoords.x = outputCoords.x - xStep;
                if (inputCoords.x >= 0) 
                {
                    if (getInputOccupancy(inputCoords)) 
                    {
                        outputDistance = xStep;
                        break;
                    }
                }

                inputCoords.x = outputCoords.x + xStep;
                if (inputCoords.x <= ${inWidth-1}) 
                {
                    if (getInputOccupancy(inputCoords)) 
                    {
                        outputDistance = xStep;
                        break;
                    }
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}
class SecondIsotropicChebyshevDistancePassY implements GPGPUProgram 
{
    variableNames = ['InputDistance']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const maxStep = Math.min(maxDistance, inHeight-1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        int getInputDistance(ivec3 coords) 
        { 
            return int(getInputDistance(coords.z, coords.y, coords.x)); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            int candidateDistance;
            int inputDistance = getInputDistance(inputCoords);
            int outputDistance = inputDistance;

            if (outputDistance <= 1) 
            {
                setOutput(float(outputDistance));
                return;
            }

            for (int yStep = 1; yStep <= ${maxStep}; yStep++) 
            {
                inputCoords.y = outputCoords.y - yStep;
                if (inputCoords.y >= 0) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, yStep);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= yStep) 
                    {
                        break;
                    }
                }

                inputCoords.y = outputCoords.y + yStep;
                if (inputCoords.y <= ${inHeight-1}) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, yStep);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= yStep) 
                    {
                        break;
                    }
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}
class ThirdIsotropicChebyshevDistancePassZ implements GPGPUProgram 
{
    variableNames = ['InputDistance']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const maxStep = Math.min(maxDistance, inDepth-1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        int getInputDistance(ivec3 coords) 
        { 
            return int(getInputDistance(coords.z, coords.y, coords.x)); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            int candidateDistance;
            int inputDistance = getInputDistance(inputCoords);
            int outputDistance = inputDistance;

            if (outputDistance <= 1) 
            {
                setOutput(float(outputDistance));
                return;
            }

            for (int zStep = 1; zStep <= ${maxStep}; zStep++) 
            {
                inputCoords.z = outputCoords.z - zStep;
                if (inputCoords.z >= 0) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, zStep);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= zStep) 
                    {
                        break;
                    }
                }

                inputCoords.z = outputCoords.z + zStep;
                if (inputCoords.z <= ${inDepth-1}) 
                {
                    inputDistance = getInputDistance(inputCoords);
                    candidateDistance = max(inputDistance, zStep);
                    outputDistance = min(outputDistance, candidateDistance);

                    if (outputDistance <= zStep) 
                    {
                        break;
                    }
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor3D 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor3D
}

export function computeIsotropicDistanceMap(occupancyMap: tf.Tensor3D, maxDistance: number): tf.Tensor3D 
{
    // 1D
    const firstPassX  = new FirstIsotropicChebyshevDistancePassX(occupancyMap.shape,  maxDistance)
    const distanceX = runProgram(firstPassX, [occupancyMap])

    // 2D
    const secondPassY = new SecondIsotropicChebyshevDistancePassY(occupancyMap.shape, maxDistance)
    const distanceXY = runProgram(secondPassY, [distanceX])
    tf.dispose(distanceX)

    // 3D
    const thirdPassZ  = new ThirdIsotropicChebyshevDistancePassZ(occupancyMap.shape,  maxDistance)
    const distanceXYZ = runProgram(thirdPassZ, [distanceXY])
    tf.dispose(distanceXY)

    return distanceXYZ
    
}