import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'


class FirstIsotropicChebyshevDistancePassX implements GPGPUProgram 
{
    variableNames = ['InputOccupancies']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inWidth-1))
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getDistancesFromOccupancies(vec4 occupancies)
        {
            return ivec4(lessThan(occupancies, vec4(0.5))) * ${maxDistance};
        }

        ivec4 getInputDistances(ivec3 coords)
        {
            return getDistancesFromOccupancies(getInputOccupancies(coords.z, coords.y, coords.x));
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;    

            ivec4 xSteps, neighborDistances, candidateDistances;
            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            
            candidateDistances = max(inputDistances.grab, 1);
            outputDistances = min(outputDistances, candidateDistances);

            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }

            for (int xStep = 2; xStep <= ${maxSteps}; xStep += 2) 
            {
                inputCoords.x = outputCoords.x - xStep;
                if (inputCoords.x >= 0) 
                {                    
                    inputDistances = getInputDistances(inputCoords);

                    xSteps.rb = ivec2(xStep);
                    xSteps.ga = ivec2(xStep - 1);

                    neighborDistances = max(inputDistances, xSteps);
                    candidateDistances.rb = min(neighborDistances.rb, neighborDistances.ga);

                    xSteps.rb = ivec2(xStep + 1);
                    xSteps.ga = ivec2(xStep);

                    neighborDistances = max(inputDistances, xSteps);
                    candidateDistances.ga = min(neighborDistances.rb, neighborDistances.ga); 

                    outputDistances = min(outputDistances, candidateDistances);
                }
                
                inputCoords.x = outputCoords.x + xStep;
                if (inputCoords.x <= ${inWidth-1}) 
                {
                    inputDistances = getInputDistances(inputCoords);
                 
                    xSteps.rb = ivec2(xStep);
                    xSteps.ga = ivec2(xStep + 1);

                    neighborDistances = max(inputDistances, xSteps);
                    candidateDistances.rb = min(neighborDistances.rb, neighborDistances.ga); 

                    xSteps.rb = ivec2(xStep - 1);
                    xSteps.ga = ivec2(xStep);

                    neighborDistances = max(inputDistances, xSteps);
                    candidateDistances.ga = min(neighborDistances.rb, neighborDistances.ga);

                    outputDistances = min(outputDistances, candidateDistances);
                }

                if (mmax(outputDistances) <= xStep + 1) 
                {
                    break;
                }
            }

            outputDistances = clamp(outputDistances, ivec4(0), ivec4(${maxDistance}));
            setOutput(vec4(outputDistances));
        }
        `
    }
}

class SecondIsotropicChebyshevDistancePassY implements GPGPUProgram 
{
    variableNames = ['InputDistances']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {        
        const [inDepth, inHeight, inWidth] = inputShape
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inHeight-1))
        this.outputShape = [inDepth, inHeight, inWidth]
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `        
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;
            
            ivec4 ySteps, neighborDistances, candidateDistances;
            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            
            candidateDistances = max(inputDistances.barg, 1);
            outputDistances = min(outputDistances, candidateDistances);

            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }

            for (int yStep = 2; yStep <= ${maxSteps}; yStep += 2) 
            {
                inputCoords.y = outputCoords.y - yStep;
                if (inputCoords.y >= 0) 
                {   
                    inputDistances = getInputDistances(inputCoords);

                    ySteps.rg = ivec2(yStep);
                    ySteps.ba = ivec2(yStep - 1);
                    
                    neighborDistances = max(inputDistances, ySteps);
                    candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);

                    ySteps.rg = ivec2(yStep + 1);
                    ySteps.ba = ivec2(yStep);

                    neighborDistances = max(inputDistances, ySteps);
                    candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);
                    
                    outputDistances = min(outputDistances, candidateDistances);
                }
                
                inputCoords.y = outputCoords.y + yStep;
                if (inputCoords.y <= ${inHeight-1}) 
                {
                    inputDistances = getInputDistances(inputCoords);

                    ySteps.rg = ivec2(yStep - 1);
                    ySteps.ba = ivec2(yStep);

                    neighborDistances = max(inputDistances, ySteps);
                    candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);

                    ySteps.rg = ivec2(yStep);
                    ySteps.ba = ivec2(yStep + 1);

                    neighborDistances = max(inputDistances, ySteps);
                    candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);
                 
                    outputDistances = min(outputDistances, candidateDistances);
                }

                if (mmax(outputDistances) <= yStep + 1) 
                {
                    break;
                }
            }

            outputDistances = clamp(outputDistances, ivec4(0), ivec4(${maxDistance}));
            setOutput(vec4(outputDistances));
        }
        `
    }
}

class ThirdIsotropicChebyshevDistancePassZ implements GPGPUProgram 
{
    variableNames = ['InputDistances']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const maxSteps = Math.min(maxDistance, inDepth-1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            ivec4 candidateDistances;

            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }

            for (int zStep = 1; zStep <= ${maxSteps}; zStep++) 
            {
                inputCoords.z = outputCoords.z - zStep;
                if (inputCoords.z >= 0) 
                {
                    inputDistances = getInputDistances(inputCoords);
                    candidateDistances = max(inputDistances, zStep);
                    outputDistances = min(outputDistances, candidateDistances);

                    if (mmax(outputDistances) <= zStep) 
                    {
                        break;
                    }
                }

                inputCoords.z = outputCoords.z + zStep;
                if (inputCoords.z < ${inDepth}) 
                {
                    inputDistances = getInputDistances(inputCoords);
                    candidateDistances = max(inputDistances, zStep);
                    outputDistances = min(outputDistances, candidateDistances);
                    
                    if (mmax(outputDistances) <= zStep) 
                    {
                        break;
                    }
                }
            }

            outputDistances = clamp(outputDistances, ivec4(0), ivec4(${maxDistance}));
            setOutput(vec4(outputDistances));
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

export function isotropicChebyshevDistanceProgramPacked(inputOccupancy: tf.Tensor3D, maxDistance: number): tf.Tensor3D 
{
    // 1D
    const firstPassX = new FirstIsotropicChebyshevDistancePassX(inputOccupancy.shape, maxDistance)
    const distanceX = runProgram(firstPassX, [inputOccupancy])

    // 2D
    const secondPassY = new SecondIsotropicChebyshevDistancePassY(inputOccupancy.shape, maxDistance)
    const distanceXY = runProgram(secondPassY, [distanceX]); 
    tf.dispose(distanceX)

    // 3D
    const thirdPassZ = new ThirdIsotropicChebyshevDistancePassZ(inputOccupancy.shape, maxDistance)
    const distanceXYZ = runProgram(thirdPassZ, [distanceXY])
    tf.dispose(distanceXY)

    return distanceXYZ
}
