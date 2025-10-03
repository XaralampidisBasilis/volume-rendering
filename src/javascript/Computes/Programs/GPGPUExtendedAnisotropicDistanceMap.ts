import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'
import { packUnsignedShort5551 } from './GPGPUToUnsignedShort5551'

class ExtendedAnisotropicChebyshevDistancePass0 implements GPGPUProgram 
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
        inputDirection: '-x' | '+x' | '-y' | '+y' | '-z' | '+z' ,     
        maxDistance: number,
    ) 
    {
        const [inSign, inAxis] = inputDirection
        const [inDepth, inHeight, inWidth] = inputShape
        this.outputShape = [inDepth, inHeight, inWidth]
        this.userCode = `
        const ivec3 maxCoords = ivec3(${inWidth-1}, ${inHeight-1}, ${inDepth-1});
        const int maxSteps = min(${maxDistance}, maxCoords.${inAxis}); 

        float getInputVariable(ivec3 coords) { return getInputVariable(coords.z, coords.y, coords.x); }

        ${inputVariable == 'occupancy' ? `
        int getInputDistance(ivec3 coords) { return int(getInputVariable(coords) < 0.5) * ${maxDistance}; }` : `
        int getInputDistance(ivec3 coords) { return int(getInputVariable(coords)); }`}

        ${inSign == '-' ? `
        bool outsideBounds(ivec3 coords) { return (coords.${inAxis} < 0); }` : `
        bool outsideBounds(ivec3 coords) { return (coords.${inAxis} > maxCoords.${inAxis}); }`}

        void main() 
        {
            ivec3 outputCoords = getOutputCoords().zyx;
            ivec3 inputCoords = outputCoords;

            int inputDistance = getInputDistance(outputCoords);
            int outputDistance = inputDistance;
            int candidateDistance;

            if (outputDistance <= 1) 
            {
                setOutput(float(outputDistance));
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
                candidateDistance = max(inputDistance, nStep);

                outputDistance = min(outputDistance, candidateDistance);
                if (outputDistance <= nStep)
                {
                    break;
                }
            }

            setOutput(float(outputDistance));
        }
        `
    }
}

class ExtendedAnisotropicChebyshevDistancePass1 implements GPGPUProgram 
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


function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function computeExtendedAnisotropicDistanceMap(inputOccupancy: tf.Tensor3D, maxDistance: number): tf.Tensor4D 
{
    const shape = inputOccupancy.shape

    // Programs
    const firstPassX0  = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'occupancy', '-x', maxDistance)
    const firstPassX1  = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'occupancy', '+x', maxDistance)
    const firstPassY0  = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'occupancy', '-y', maxDistance)
    const firstPassY1  = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'occupancy', '+y', maxDistance)
    const secondPassY0 = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'distance',  '-y', maxDistance)
    const secondPassY1 = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'distance',  '+y', maxDistance)
    const secondPassZ0 = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'distance',  '-z', maxDistance)
    const secondPassZ1 = new ExtendedAnisotropicChebyshevDistancePass0(shape, 'distance',  '+z', maxDistance)
    const thirdPassX0  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '-x', maxDistance)
    const thirdPassX1  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '+x', maxDistance)
    const thirdPassY0  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '-y', maxDistance)
    const thirdPassY1  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '+y', maxDistance)
    const thirdPassZ0  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '-z', maxDistance)
    const thirdPassZ1  = new ExtendedAnisotropicChebyshevDistancePass1(shape, '+z', maxDistance)

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
