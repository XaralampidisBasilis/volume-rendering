import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'
import { packUnsignedShort5551 } from './GPGPUToUnsignedShort5551Packed'

class FirstExtendedAnisotropicChebyshevDistancePassX implements GPGPUProgram 
{
    variableNames = ['InputOccupancies']
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
        const maxSteps = ceilToEven(Math.min(maxDistance, inWidth - 1))
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

        bool outsideWidth(ivec3 coords)
        {
            return (coords.x < 0) || (coords.x > ${inWidth-1});
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        const int xSign = ${inputSign} 1;

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            ivec4 neighborDistances, candidateDistances, xSteps;

            ${inputSign == '-' ? 
            `
                xSteps.rb = ivec2(0 - xSign);
                xSteps.ga = ivec2(0);

                neighborDistances = max(inputDistances, xSteps);
                candidateDistances.ga = min(neighborDistances.rb, neighborDistances.ga);
                candidateDistances.rb = neighborDistances.rb;

            `:`
                xSteps.rb = ivec2(0);
                xSteps.ga = ivec2(0 + xSign);

                neighborDistances = max(inputDistances, xSteps);
                candidateDistances.ga = neighborDistances.ga;
                candidateDistances.rb = min(neighborDistances.rb, neighborDistances.ga);
            `}

            outputDistances = min(outputDistances, candidateDistances);
            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }
            
            for (int xStep = 2; xStep <= ${maxSteps}; xStep += 2) 
            {
                inputCoords.x = outputCoords.x + xStep * xSign;
                if (outsideWidth(inputCoords)) 
                {
                    break;                    
                }

                inputDistances = getInputDistances(inputCoords);

                xSteps.rb = ivec2(xStep - xSign);
                xSteps.ga = ivec2(xStep);

                neighborDistances = max(inputDistances, xSteps);
                candidateDistances.ga = min(neighborDistances.rb, neighborDistances.ga); 

                xSteps.rb = ivec2(xStep);
                xSteps.ga = ivec2(xStep + xSign);

                neighborDistances = max(inputDistances, xSteps);
                candidateDistances.rb = min(neighborDistances.rb, neighborDistances.ga);

                outputDistances = min(outputDistances, candidateDistances);
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

class FirstExtendedAnisotropicChebyshevDistancePassY implements GPGPUProgram 
{
    variableNames = ['InputOccupancies']
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
        const [inDepth, inHeight, inWidth] = inputShape; 
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inHeight - 1))
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

        bool outsideHeight(ivec3 coords)
        {
            return (coords.y < 0) || (coords.y > ${inHeight-1});
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        const int ySign = ${inputSign} 1;

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;    

            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            ivec4 neighborDistances, candidateDistances, ySteps;

            ${inputSign == '-' ? 
            `   
                ySteps.rg = ivec2(0 - ySign);
                ySteps.ba = ivec2(0);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);
                candidateDistances.rg = neighborDistances.rg;
            `:`
                ySteps.rg = ivec2(0);
                ySteps.ba = ivec2(0 + ySign);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = neighborDistances.ba;
                candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);
            `}

            outputDistances = min(outputDistances, candidateDistances);
            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }

            for (int yStep = 2; yStep <= ${maxSteps}; yStep += 2) 
            {
                inputCoords.y = outputCoords.y + yStep * ySign;
                if (outsideHeight(inputCoords)) 
                {
                    break;   
                }
                
                inputDistances = getInputDistances(inputCoords);

                ySteps.rg = ivec2(yStep - ySign);
                ySteps.ba = ivec2(yStep);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);

                ySteps.rg = ivec2(yStep);
                ySteps.ba = ivec2(yStep + ySign);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);
                
                outputDistances = min(outputDistances, candidateDistances);
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

class SecondExtendedAnisotropicChebyshevDistancePassY implements GPGPUProgram 
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
        const [inDepth, inHeight, inWidth] = inputShape; 
        const ceilToEven = (x: number) => Math.ceil(x / 2) * 2
        const maxSteps = ceilToEven(Math.min(maxDistance, inHeight - 1))
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `        
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        bool outsideHeight(ivec3 coords)
        {
            return (coords.y < 0) || (coords.y > ${inHeight-1});
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        const int ySign = ${inputSign} 1;

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;    

            ivec4 inputDistances = getInputDistances(inputCoords);
            ivec4 outputDistances = inputDistances;
            ivec4 neighborDistances, candidateDistances, ySteps;

            ${inputSign == '-' ? 
            `   
                ySteps.rg = ivec2(0 - ySign);
                ySteps.ba = ivec2(0);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);
                candidateDistances.rg = neighborDistances.rg;
            `:`
                ySteps.rg = ivec2(0);
                ySteps.ba = ivec2(0 + ySign);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = neighborDistances.ba;
                candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);
            `}

            outputDistances = min(outputDistances, candidateDistances);
            if (mmax(outputDistances) <= 1) 
            {
                setOutput(vec4(outputDistances));
                return;
            }

            for (int yStep = 2; yStep <= ${maxSteps}; yStep += 2) 
            {
                inputCoords.y = outputCoords.y + yStep * ySign;
                if (outsideHeight(inputCoords)) 
                {
                    break;   
                }
                
                inputDistances = getInputDistances(inputCoords);

                ySteps.rg = ivec2(yStep - ySign);
                ySteps.ba = ivec2(yStep);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.ba = min(neighborDistances.rg, neighborDistances.ba);

                ySteps.rg = ivec2(yStep);
                ySteps.ba = ivec2(yStep + ySign);

                neighborDistances = max(inputDistances, ySteps);
                candidateDistances.rg = min(neighborDistances.rg, neighborDistances.ba);
                
                outputDistances = min(outputDistances, candidateDistances);
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

class SecondExtendedAnisotropicChebyshevDistancePassZ implements GPGPUProgram 
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
        const maxSteps = Math.min(maxDistance, inDepth - 1)
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        ivec4 getInputDistances(ivec3 coords) 
        { 
            return ivec4(getInputDistances(coords.z, coords.y, coords.x)); 
        }

        bool outsideDepth(ivec3 coords)
        {
            return (coords.z < 0) || (coords.z > ${inDepth-1});
        }

        int mmax(ivec4 distances) 
        { 
            return max(max(distances.x, distances.y), max(distances.z, distances.w)); 
        }

        const int zSign = ${inputSign} 1;

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
                inputCoords.z = outputCoords.z + zStep * zSign;
                if (outsideDepth(inputCoords))
                {
                    break;
                }

                inputDistances = getInputDistances(inputCoords);
                candidateDistances = max(inputDistances, zStep);

                outputDistances = min(outputDistances, candidateDistances); 
                if (mmax(outputDistances) <= zStep + 1) 
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

class ThirdExtendedAnisotropicChebyshevDistancePassX implements GPGPUProgram 
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

class ThirdExtendedAnisotropicChebyshevDistancePassY implements GPGPUProgram 
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

class ThirdExtendedAnisotropicChebyshevDistancePassZ implements GPGPUProgram 
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
    return tf.engine().makeTensorFromTensorInfo(backend.compileAndRun(prog, inputs))
}

export function computeExtendedAnisotropicDistanceMap(inputOccupancy: tf.Tensor3D, maxDistance: number): tf.Tensor4D 
{
    const shape = inputOccupancy.shape

    // Programs
    const firstPassX0  = new FirstExtendedAnisotropicChebyshevDistancePassX(shape, '-', maxDistance)
    const firstPassX1  = new FirstExtendedAnisotropicChebyshevDistancePassX(shape, '+', maxDistance)
    const firstPassY0  = new FirstExtendedAnisotropicChebyshevDistancePassY(shape, '-', maxDistance)
    const firstPassY1  = new FirstExtendedAnisotropicChebyshevDistancePassY(shape, '+', maxDistance)
    const secondPassY0 = new SecondExtendedAnisotropicChebyshevDistancePassY(shape, '-', maxDistance)
    const secondPassY1 = new SecondExtendedAnisotropicChebyshevDistancePassY(shape, '+', maxDistance)
    const secondPassZ0 = new SecondExtendedAnisotropicChebyshevDistancePassZ(shape, '-', maxDistance)
    const secondPassZ1 = new SecondExtendedAnisotropicChebyshevDistancePassZ(shape, '+', maxDistance)
    const thirdPassX0  = new ThirdExtendedAnisotropicChebyshevDistancePassX(shape, '-', maxDistance)
    const thirdPassX1  = new ThirdExtendedAnisotropicChebyshevDistancePassX(shape, '+', maxDistance)
    const thirdPassY0  = new ThirdExtendedAnisotropicChebyshevDistancePassY(shape, '-', maxDistance)
    const thirdPassY1  = new ThirdExtendedAnisotropicChebyshevDistancePassY(shape, '+', maxDistance)
    const thirdPassZ0  = new ThirdExtendedAnisotropicChebyshevDistancePassZ(shape, '-', maxDistance)
    const thirdPassZ1  = new ThirdExtendedAnisotropicChebyshevDistancePassZ(shape, '+', maxDistance)

    // 1D
    const distance_X0 = runProgram(firstPassX0, [inputOccupancy])
    const distance_X1 = runProgram(firstPassX1, [inputOccupancy])
    const distance_Y0 = runProgram(firstPassY0, [inputOccupancy])
    const distance_Y1 = runProgram(firstPassY1, [inputOccupancy])

    // 2D
    const distance_XY00 = runProgram(secondPassY0, [distance_X0]);
    const distance_XY01 = runProgram(secondPassY1, [distance_X0]); 
    const distance_XZ00 = runProgram(secondPassZ0, [distance_X0]);
    const distance_XZ01 = runProgram(secondPassZ1, [distance_X0]); tf.dispose(distance_X0)
    const distance_XY10 = runProgram(secondPassY0, [distance_X1]);
    const distance_XY11 = runProgram(secondPassY1, [distance_X1]); 
    const distance_XZ10 = runProgram(secondPassZ0, [distance_X1]);
    const distance_XZ11 = runProgram(secondPassZ1, [distance_X1]); tf.dispose(distance_X1)
    const distance_YZ00 = runProgram(secondPassZ0, [distance_Y0]);
    const distance_YZ01 = runProgram(secondPassZ1, [distance_Y0]); tf.dispose(distance_Y0)
    const distance_YZ10 = runProgram(secondPassZ0, [distance_Y1]);
    const distance_YZ11 = runProgram(secondPassZ1, [distance_Y1]); tf.dispose(distance_Y1)

    // 3D
    const distanceX_XYZ000 = runProgram(thirdPassX0, [distance_YZ00]);
    const distanceX_XYZ100 = runProgram(thirdPassX1, [distance_YZ00]); tf.dispose(distance_YZ00)
    const distanceX_XYZ001 = runProgram(thirdPassX0, [distance_YZ01]);
    const distanceX_XYZ101 = runProgram(thirdPassX1, [distance_YZ01]); tf.dispose(distance_YZ01)
    const distanceX_XYZ010 = runProgram(thirdPassX0, [distance_YZ10]);
    const distanceX_XYZ110 = runProgram(thirdPassX1, [distance_YZ10]); tf.dispose(distance_YZ10)
    const distanceX_XYZ011 = runProgram(thirdPassX0, [distance_YZ11]);
    const distanceX_XYZ111 = runProgram(thirdPassX1, [distance_YZ11]); tf.dispose(distance_YZ11)
    const distanceY_XYZ000 = runProgram(thirdPassY0, [distance_XZ00]);
    const distanceY_XYZ010 = runProgram(thirdPassY1, [distance_XZ00]); tf.dispose(distance_XZ00)
    const distanceY_XYZ001 = runProgram(thirdPassY0, [distance_XZ01]);
    const distanceY_XYZ011 = runProgram(thirdPassY1, [distance_XZ01]); tf.dispose(distance_XZ01)
    const distanceY_XYZ100 = runProgram(thirdPassY0, [distance_XZ10]);
    const distanceY_XYZ110 = runProgram(thirdPassY1, [distance_XZ10]); tf.dispose(distance_XZ10)
    const distanceY_XYZ101 = runProgram(thirdPassY0, [distance_XZ11]);
    const distanceY_XYZ111 = runProgram(thirdPassY1, [distance_XZ11]); tf.dispose(distance_XZ11)
    const distanceZ_XYZ000 = runProgram(thirdPassZ0, [distance_XY00]);
    const distanceZ_XYZ001 = runProgram(thirdPassZ1, [distance_XY00]); tf.dispose(distance_XY00)
    const distanceZ_XYZ010 = runProgram(thirdPassZ0, [distance_XY01]);
    const distanceZ_XYZ011 = runProgram(thirdPassZ1, [distance_XY01]); tf.dispose(distance_XY01)
    const distanceZ_XYZ100 = runProgram(thirdPassZ0, [distance_XY10]);
    const distanceZ_XYZ101 = runProgram(thirdPassZ1, [distance_XY10]); tf.dispose(distance_XY10)
    const distanceZ_XYZ110 = runProgram(thirdPassZ0, [distance_XY11]);
    const distanceZ_XYZ111 = runProgram(thirdPassZ1, [distance_XY11]); tf.dispose(distance_XY11)

    // Packing
    const distancesXYZ_XYZ000 = packUnsignedShort5551(distanceX_XYZ000, distanceY_XYZ000, distanceZ_XYZ000, inputOccupancy);  tf.dispose([distanceX_XYZ000, distanceY_XYZ000, distanceZ_XYZ000])
    const distancesXYZ_XYZ001 = packUnsignedShort5551(distanceX_XYZ001, distanceY_XYZ001, distanceZ_XYZ001, inputOccupancy);  tf.dispose([distanceX_XYZ001, distanceY_XYZ001, distanceZ_XYZ001])
    const distancesXYZ_XYZ010 = packUnsignedShort5551(distanceX_XYZ010, distanceY_XYZ010, distanceZ_XYZ010, inputOccupancy);  tf.dispose([distanceX_XYZ010, distanceY_XYZ010, distanceZ_XYZ010])
    const distancesXYZ_XYZ011 = packUnsignedShort5551(distanceX_XYZ011, distanceY_XYZ011, distanceZ_XYZ011, inputOccupancy);  tf.dispose([distanceX_XYZ011, distanceY_XYZ011, distanceZ_XYZ011])
    const distancesXYZ_XYZ100 = packUnsignedShort5551(distanceX_XYZ100, distanceY_XYZ100, distanceZ_XYZ100, inputOccupancy);  tf.dispose([distanceX_XYZ100, distanceY_XYZ100, distanceZ_XYZ100])
    const distancesXYZ_XYZ101 = packUnsignedShort5551(distanceX_XYZ101, distanceY_XYZ101, distanceZ_XYZ101, inputOccupancy);  tf.dispose([distanceX_XYZ101, distanceY_XYZ101, distanceZ_XYZ101])
    const distancesXYZ_XYZ110 = packUnsignedShort5551(distanceX_XYZ110, distanceY_XYZ110, distanceZ_XYZ110, inputOccupancy);  tf.dispose([distanceX_XYZ110, distanceY_XYZ110, distanceZ_XYZ110])
    const distancesXYZ_XYZ111 = packUnsignedShort5551(distanceX_XYZ111, distanceY_XYZ111, distanceZ_XYZ111, inputOccupancy);  tf.dispose([distanceX_XYZ111, distanceY_XYZ111, distanceZ_XYZ111])

    // Concatenate 
    const distancesXYZ_XYZ000_XYZ100_XYZ010_XYZ110_XYZ001_XYZ101_XYZ011_XYZ111 = tf.stack([
        distancesXYZ_XYZ000,
        distancesXYZ_XYZ100,
        distancesXYZ_XYZ010,
        distancesXYZ_XYZ110,
        distancesXYZ_XYZ001,
        distancesXYZ_XYZ101,
        distancesXYZ_XYZ011,
        distancesXYZ_XYZ111,
    ], 0)

    tf.dispose([
        distancesXYZ_XYZ000,
        distancesXYZ_XYZ100,
        distancesXYZ_XYZ010,
        distancesXYZ_XYZ110,
        distancesXYZ_XYZ001,
        distancesXYZ_XYZ101,
        distancesXYZ_XYZ011,
        distancesXYZ_XYZ111,
    ])
            
    return distancesXYZ_XYZ000_XYZ100_XYZ010_XYZ110_XYZ001_XYZ101_XYZ011_XYZ111 as tf.Tensor4D
}
