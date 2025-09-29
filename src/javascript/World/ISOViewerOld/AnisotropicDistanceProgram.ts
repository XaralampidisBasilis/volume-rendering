import * as tf from '@tensorflow/tfjs'
import { GPGPUProgram } from '@tensorflow/tfjs-backend-webgl'
import { MathBackendWebGL } from '@tensorflow/tfjs-backend-webgl'


class AnisotropicChebyshevDistancePass implements GPGPUProgram 
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

function runProgram(prog: GPGPUProgram, inputs: tf.Tensor[]) : tf.Tensor 
{
    const backend = tf.backend() as MathBackendWebGL
    const info = backend.compileAndRun(prog, inputs)
    return tf.engine().makeTensorFromTensorInfo(info) as tf.Tensor
}

export function anisotropicChebyshevDistanceProgram(inputOccupancy: tf.Tensor3D, maxDistance: number): tf.Tensor4D 
{
    const shape = inputOccupancy.shape

    // 1D 
    const firstPassX0  = new AnisotropicChebyshevDistancePass(shape, 'occupancy', '-x', maxDistance)
    const firstPassX1  = new AnisotropicChebyshevDistancePass(shape, 'occupancy', '+x', maxDistance)
    const distanceX0 = runProgram(firstPassX0, [inputOccupancy])
    const distanceX1 = runProgram(firstPassX1, [inputOccupancy])

    // 2D
    const secondPassY0 = new AnisotropicChebyshevDistancePass(shape, 'distance', '-y', maxDistance)
    const secondPassY1 = new AnisotropicChebyshevDistancePass(shape, 'distance', '+y', maxDistance)
    const distanceXY00 = runProgram(secondPassY0, [distanceX0]);
    const distanceXY01 = runProgram(secondPassY1, [distanceX0]); tf.dispose(distanceX0)
    const distanceXY10 = runProgram(secondPassY0, [distanceX1]);
    const distanceXY11 = runProgram(secondPassY1, [distanceX1]); tf.dispose(distanceX1)

    // 3D
    const thirdPassZ0  = new AnisotropicChebyshevDistancePass(shape, 'distance', '-z', maxDistance)
    const thirdPassZ1  = new AnisotropicChebyshevDistancePass(shape, 'distance', '+z', maxDistance)
    const distanceXYZ000 = runProgram(thirdPassZ0, [distanceXY00]);
    const distanceXYZ001 = runProgram(thirdPassZ1, [distanceXY00]); tf.dispose(distanceXY00)
    const distanceXYZ010 = runProgram(thirdPassZ0, [distanceXY01]);
    const distanceXYZ011 = runProgram(thirdPassZ1, [distanceXY01]); tf.dispose(distanceXY01)
    const distanceXYZ100 = runProgram(thirdPassZ0, [distanceXY10]);
    const distanceXYZ101 = runProgram(thirdPassZ1, [distanceXY10]); tf.dispose(distanceXY10)
    const distanceXYZ110 = runProgram(thirdPassZ0, [distanceXY11]);
    const distanceXYZ111 = runProgram(thirdPassZ1, [distanceXY11]); tf.dispose(distanceXY11)
    
    // Stack
    const distance_XYZ000_XYZ100_XYZ010_XYZ110_XYZ001_XYZ101_XYZ011_XYZ111 = tf.stack([
        distanceXYZ000,
        distanceXYZ100,
        distanceXYZ010,
        distanceXYZ110,
        distanceXYZ001,
        distanceXYZ101,
        distanceXYZ011,
        distanceXYZ111,
    ], 0)

    tf.dispose([
        distanceXYZ000,
        distanceXYZ100,
        distanceXYZ010,
        distanceXYZ110,
        distanceXYZ001,
        distanceXYZ101,
        distanceXYZ011,
        distanceXYZ111,
    ])

    return distance_XYZ000_XYZ100_XYZ010_XYZ110_XYZ001_XYZ101_XYZ011_XYZ111 as tf.Tensor4D
}