import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'
import { packUnsignedShort5551 } from './GPGPUToUnsignedShort5551Packed'

class FirstExtendedIsotropicChebyshevDistancePassX implements GPGPUProgram 
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

class FirstExtendedIsotropicChebyshevDistancePassY implements GPGPUProgram 
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
        const maxSteps = ceilToEven(Math.min(maxDistance, inHeight-1))
        this.outputShape = [inDepth, inHeight, inWidth]
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

class SecondExtendedIsotropicChebyshevDistancePassY implements GPGPUProgram 
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

class SecondExtendedIsotropicChebyshevDistancePassZ implements GPGPUProgram 
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

class ThirdExtendedIsotropicChebyshevDistancePassX implements GPGPUProgram 
{
    variableNames = ['InputDistances']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        inputSign: '-' | '+',
        maxDistance: number,
    ) 
    {        
        const [inDepth, inHeight, inWidth] = inputShape
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inWidth-1))
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        bool outsideWidth(ivec3 coords) 
        { 
            return coords.x < 0 || coords.x > ${inWidth-1}; 
        }

        int mmax(ivec4 vec) 
        { 
            return max(max(vec.x, vec.y), max(vec.z, vec.w)); 
        }

        ivec4 mmix(ivec4 a, ivec4 b, bvec4 mask) 
        {
            return ivec4(mask) * (b - a) + a;
        }

        const ivec4 maxDistances = ivec4(${maxDistance});
        const int xSign = ${inputSign} 1;

        void main() 
        {            
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            ivec4 outputDistances = maxDistances;
            ivec4 inputDistances, neighborDistances, candidateDistances, xSteps;
        
            for (int xStep = 0; xStep <= ${maxSteps}; xStep += 2) 
            {
                inputCoords.x = outputCoords.x + xStep * xSign;
                if (outsideWidth(inputCoords))
                {
                    break;
                }

                inputDistances = getInputDistances(inputCoords);

                xSteps.ga = ivec2(xStep);
                xSteps.rb = ivec2(xStep - xSign);

                neighborDistances = mmix(maxDistances, xSteps, lessThanEqual(inputDistances, xSteps));
                candidateDistances.ga = min(neighborDistances.rb, neighborDistances.ga);

                xSteps.ga = ivec2(xStep + xSign);
                xSteps.rb = ivec2(xStep);

                neighborDistances = mmix(maxDistances, xSteps, lessThanEqual(inputDistances, xSteps));
                candidateDistances.rb = min(neighborDistances.rb, neighborDistances.ga);

                outputDistances = min(outputDistances, candidateDistances);
                if (mmax(outputDistances) <= xStep + 1) 
                {
                    break;
                }
            }

            outputDistances = clamp(outputDistances, 0, ${maxDistance});
            setOutput(vec4(outputDistances));
        }
        `
    }
}

class ThirdExtendedIsotropicChebyshevDistancePassY implements GPGPUProgram 
{
    variableNames = ['InputDistances']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        inputSign: '-' | '+',
        maxDistance: number,
    ) 
    {        
        const [inDepth, inHeight, inWidth] = inputShape
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inHeight-1))
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        bool outsideHeight(ivec3 coords) 
        { 
            return coords.y < 0 || coords.y > ${inHeight-1}; 
        }
       
        int mmax(ivec4 vec) 
        { 
            return max(max(vec.x, vec.y), max(vec.z, vec.w)); 
        }

        ivec4 mmix(ivec4 a, ivec4 b, bvec4 mask) 
        {
            return ivec4(mask) * (b - a) + a;
        }

        const ivec4 maxDistances = ivec4(${maxDistance});
        const int ySign = ${inputSign} 1;

        void main() 
        {            
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            ivec4 outputDistances = maxDistances;
            ivec4 inputDistances, neighborDistances, candidateDistances, ySteps;
        
            for (int yStep = 0; yStep <= ${maxSteps}; yStep += 2) 
            {
                inputCoords.y = outputCoords.y + yStep * ySign;
                if (outsideHeight(inputCoords))
                {
                    break;
                }

                inputDistances = getInputDistances(inputCoords);

                ySteps.ba = ivec2(yStep);
                ySteps.rg = ivec2(yStep - ySign);

                neighborDistances = mmix(maxDistances, ySteps, lessThanEqual(inputDistances, ySteps));
                candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);

                ySteps.ba = ivec2(yStep + ySign);
                ySteps.rg = ivec2(yStep);

                neighborDistances = mmix(maxDistances, ySteps, lessThanEqual(inputDistances, ySteps));
                candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);

                outputDistances = min(outputDistances, candidateDistances);
                if (mmax(outputDistances) <= yStep + 1) 
                {
                    break;
                }
            }

            outputDistances = clamp(outputDistances, 0, ${maxDistance});
            setOutput(vec4(outputDistances));
        }
        `
    }
}

class ThirdExtendedIsotropicChebyshevDistancePassZ implements GPGPUProgram 
{
    variableNames = ['InputDistances']
    outputShape: number[]
    userCode: string
    packedInputs = true
    packedOutput = true

    constructor
    (
        inputShape: [number, number, number], 
        inputSign: '-' | '+',
        maxDistance: number,
    ) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        const maxSteps = Math.min(maxDistance, inDepth-1);
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        bool outsideDepth(ivec3 coords) 
        { 
            return coords.z < 0 || coords.z > ${inDepth-1}; 
        }
       
        int mmax(ivec4 vec) 
        { 
            return max(max(vec.x, vec.y), max(vec.z, vec.w)); 
        }

        ivec4 mmix(ivec4 a, ivec4 b, bvec4 mask) 
        {
            return ivec4(mask) * (b - a) + a;
        }

        const ivec4 maxDistances = ivec4(${maxDistance});
        const int zSign = ${inputSign} 1;

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            ivec4 outputDistances = maxDistances;
            ivec4 inputDistances, candidateDistances, zSteps;
            
            for (int zStep = 0; zStep <= ${maxSteps}; zStep++) 
            {
                inputCoords.z = outputCoords.z + zStep * zSign;
                if (outsideDepth(inputCoords))
                {
                    break;
                }

                zSteps = ivec4(zStep);
                inputDistances = getInputDistances(inputCoords);
                candidateDistances = mmix(maxDistances, zSteps, lessThanEqual(inputDistances, zSteps));

                outputDistances = min(outputDistances, candidateDistances);
                if (mmax(outputDistances) <= zStep + 1) 
                {
                    break;
                }
            }

            outputDistances = clamp(outputDistances, 0, ${maxDistance});
            setOutput(vec4(outputDistances));
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

export function computeExtendedIsotropicDistanceMap(inputOccupancy: tf.Tensor3D, maxDistance: number): tf.Tensor
{
    const shape = inputOccupancy.shape

    // Programs
    const firstPassX  = new FirstExtendedIsotropicChebyshevDistancePassX(shape, maxDistance)
    const firstPassY  = new FirstExtendedIsotropicChebyshevDistancePassY(shape, maxDistance)
    const secondPassY = new SecondExtendedIsotropicChebyshevDistancePassY(shape, maxDistance)
    const secondPassZ = new SecondExtendedIsotropicChebyshevDistancePassZ(shape,  maxDistance)
    const thirdPassX0 = new ThirdExtendedIsotropicChebyshevDistancePassX(shape, '-', maxDistance)
    const thirdPassX1 = new ThirdExtendedIsotropicChebyshevDistancePassX(shape, '+', maxDistance)
    const thirdPassY0 = new ThirdExtendedIsotropicChebyshevDistancePassY(shape, '-', maxDistance)
    const thirdPassY1 = new ThirdExtendedIsotropicChebyshevDistancePassY(shape, '+', maxDistance)
    const thirdPassZ0 = new ThirdExtendedIsotropicChebyshevDistancePassZ(shape, '-', maxDistance)
    const thirdPassZ1 = new ThirdExtendedIsotropicChebyshevDistancePassZ(shape, '+', maxDistance)

    // 1D
    const distance_X = runProgram(firstPassX, [inputOccupancy])
    const distance_Y = runProgram(firstPassY, [inputOccupancy])

    // 2D
    const distance_XY = runProgram(secondPassY, [distance_X]);
    const distance_XZ = runProgram(secondPassZ, [distance_X]); tf.dispose(distance_X)
    const distance_YZ = runProgram(secondPassZ, [distance_Y]); tf.dispose(distance_Y)

    // 3D
    const distanceX0_XYZ = runProgram(thirdPassX0, [distance_YZ]);
    const distanceX1_XYZ = runProgram(thirdPassX1, [distance_YZ]); tf.dispose(distance_YZ)
    const distanceY0_XYZ = runProgram(thirdPassY0, [distance_XZ]);
    const distanceY1_XYZ = runProgram(thirdPassY1, [distance_XZ]); tf.dispose(distance_XZ)
    const distanceZ0_XYZ = runProgram(thirdPassZ0, [distance_XY]);
    const distanceZ1_XYZ = runProgram(thirdPassZ1, [distance_XY]); tf.dispose(distance_XY)

    // Pack distances
    const distances_X0_Y0_Z0_XYZ = packUnsignedShort5551(distanceX0_XYZ, distanceY0_XYZ, distanceZ0_XYZ, inputOccupancy); tf.dispose([distanceX0_XYZ, distanceY0_XYZ, distanceZ0_XYZ])
    const distances_X1_Y1_Z1_XYZ = packUnsignedShort5551(distanceX1_XYZ, distanceY1_XYZ, distanceZ1_XYZ, inputOccupancy); tf.dispose([distanceX1_XYZ, distanceY1_XYZ, distanceZ1_XYZ])
    
    // Stack channels
    const distances_X0_Y0_Z0_X1_Y1_Z1_XYZ = tf.stack([distances_X0_Y0_Z0_XYZ, distances_X1_Y1_Z1_XYZ], -1); tf.dispose([distances_X0_Y0_Z0_XYZ, distances_X1_Y1_Z1_XYZ])
    return distances_X0_Y0_Z0_X1_Y1_Z1_XYZ as tf.Tensor3D
}
