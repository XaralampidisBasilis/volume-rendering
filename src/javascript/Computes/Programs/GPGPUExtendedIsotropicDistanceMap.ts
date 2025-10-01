import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'

class ExtendedIsotropicChebyshevDistancePass0 implements GPGPUProgram 
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

class ExtendedIsotropicChebyshevDistancePass1 implements GPGPUProgram 
{
    variableNames = ['InputDistance']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor
    (
        inputShape: [number, number, number], 
        inputDirection: '-x' | '+x' | '-y' | '+y' | '-z' | '+z',     
        maxDistance: number
    ) 
    {
        const [inSign, inAxis] = inputDirection
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]

        this.userCode = `
        const ivec3 maxCoords = ivec3(${inWidth-1}, ${inHeight-1}, ${inDepth-1});
        const int maxSteps = min(${maxDistance}, maxCoords.${inAxis}); 
        
        ${inSign == '-' ? `
        bool outsideBounds(ivec3 coords) { return coords.${inAxis} < 0; }` : `
        bool outsideBounds(ivec3 coords) { return coords.${inAxis} > maxCoords.${inAxis}; }`}
        
        int getInputDistance(ivec3 coords) { return int(getInputDistance(coords.z, coords.y, coords.x)); }

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            int inputDistance = getInputDistance(outputCoords);
            int outputDistance = ${maxDistance};

            if (inputDistance == 0) 
            {
                setOutput(0.0);
                return;
            }
            
            for (int nStep = 1; nStep <= maxSteps; nStep++) 
            {
                inputCoords.${inAxis} = outputCoords.${inAxis} ${inSign} nStep;
                if (outsideBounds(inputCoords)) 
                {
                    break;
                }

                inputDistance = getInputDistance(inputCoords);
                if (inputDistance <= nStep)
                {
                    outputDistance = nStep;
                    break;
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}

class ExtendedIsotropicChebyshevDistancePass2 implements GPGPUProgram 
{
    variableNames = ['XDistance', 'YDistance', 'ZDistance', 'Occupancy']
    outputShape: number[]
    userCode: string
    packedInputs = false
    packedOutput = false

    constructor(inputShape: [number, number, number]) 
    {
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        uint pack5551(uint x, uint y, uint z, uint o)
        {
            uint up16 = 
            ((x & 0x1Fu) << 11) |
            ((y & 0x1Fu) <<  6) |
            ((z & 0x1Fu) <<  1) |
            ((o & 0x01u) <<  0);

            return up16;
        }

        float uintHalfBitsToHalfFloat(uint packed)
        {
            return unpackHalf2x16(packed).r;
        }

        void main() 
        {
            uint xDistance = uint(getXDistanceAtOutCoords());
            uint yDistance = uint(getYDistanceAtOutCoords());
            uint zDistance = uint(getZDistanceAtOutCoords());
            uint occupancy = uint(getOccupancyAtOutCoords());
            
            uint packedOutput = pack5551(xDistance, yDistance, zDistance, occupancy);
            setOutput(uintHalfBitsToHalfFloat(packedOutput));
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
    const firstPassX  = new ExtendedIsotropicChebyshevDistancePass0(shape, 'occupancy', 'x', maxDistance)
    const firstPassY  = new ExtendedIsotropicChebyshevDistancePass0(shape, 'occupancy', 'y', maxDistance)
    const secondPassY = new ExtendedIsotropicChebyshevDistancePass0(shape, 'distance',  'y', maxDistance)
    const secondPassZ = new ExtendedIsotropicChebyshevDistancePass0(shape, 'distance',  'z', maxDistance)
    const thirdPassX0 = new ExtendedIsotropicChebyshevDistancePass1(shape, '-x', maxDistance)
    const thirdPassX1 = new ExtendedIsotropicChebyshevDistancePass1(shape, '+x', maxDistance)
    const thirdPassY0 = new ExtendedIsotropicChebyshevDistancePass1(shape, '-y', maxDistance)
    const thirdPassY1 = new ExtendedIsotropicChebyshevDistancePass1(shape, '+y', maxDistance)
    const thirdPassZ0 = new ExtendedIsotropicChebyshevDistancePass1(shape, '-z', maxDistance)
    const thirdPassZ1 = new ExtendedIsotropicChebyshevDistancePass1(shape, '+z', maxDistance)
    const fourthPass  = new ExtendedIsotropicChebyshevDistancePass2(shape)

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

    // Packing
    const distances_X0_Y0_Z0_XYZ = runProgram(fourthPass, [distanceX0_XYZ, distanceY0_XYZ, distanceZ0_XYZ, inputOccupancy]); tf.dispose([distanceX0_XYZ, distanceY0_XYZ, distanceZ0_XYZ, inputOccupancy])
    const distances_X1_Y1_Z1_XYZ = runProgram(fourthPass, [distanceX1_XYZ, distanceY1_XYZ, distanceZ1_XYZ, inputOccupancy]); tf.dispose([distanceX1_XYZ, distanceY1_XYZ, distanceZ1_XYZ, inputOccupancy])

    const distances_X0_Y0_Z0_X1_Y1_Z1_XYZ = tf.stack([distances_X0_Y0_Z0_XYZ, distances_X1_Y1_Z1_XYZ], -1)
    tf.dispose([distances_X0_Y0_Z0_XYZ, distances_X1_Y1_Z1_XYZ])
    
    return distances_X0_Y0_Z0_X1_Y1_Z1_XYZ as tf.Tensor3D
}
