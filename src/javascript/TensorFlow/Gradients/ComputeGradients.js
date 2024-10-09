import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Scharr from './Kernels/Scharr'
import Sobel from './Kernels/Sobel'
import Prewitt from './Kernels/Prewitt'
import Tetrahedron from './Kernels/Tetrahedron'
import Central from './Kernels/Central'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradients
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.method = this.viewer.material.defines.GRADIENT_METHOD
        this.kernels = this.generate()
    }

    generate() {

        switch (this.method) 
        {
            case 1: return new Scharr()
            case 2: return new Sobel()
            case 3: return new Prewitt()
            case 4: return new Tetrahedron()
            case 5: return new Central()
            default: 
                throw new Error(`Unknown GRADIENT_METHOD: ${this.method}`);
        }
    }
    

    async compute()
    {   
        // applying the X convolution filter to the volume data.
        const gradientX1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.x, 1, 'same')

        // normalize the gradient along X by dividing by the voxel spacing in X direction.
        const gradientX = gradientX1.div([this.parameters.volume.spacing.x])
        gradientX1.dispose() 

        // applying the Y convolution filter to the volume data.
        const gradientY1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.y, 1, 'same')

        // normalize the gradient along Y by dividing by the voxel spacing in Y direction.
        const gradientY = gradientY1.div([this.parameters.volume.spacing.y])
        gradientY1.dispose() 

        // applying the Z convolution filter to the volume data.
        const gradientZ1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.z, 1, 'same')

        // normalize the gradient along Z by dividing by the voxel spacing in Z direction.
        const gradientZ = gradientZ1.div([this.parameters.volume.spacing.z])
        gradientZ1.dispose() 

        // concatenate the three gradients (X, Y, Z) along the 4th dimension to form the complete gradient vector field.
        const gradients = tf.concat([gradientX, gradientY, gradientZ], 3); 
        gradientX.dispose() 
        gradientY.dispose() 
        gradientZ.dispose() 

        // compute the Euclidean norm of the gradients along the 4th dimension (3D vectors).
        const gradientsNorm1 = tf.norm(gradients, 'euclidean', 3).reshape([-1])
        const gradientsNorm = gradientsNorm1.reshape([-1])
        gradientsNorm1.dispose() 

        // find the smallest element among the top 1% (0.001) of the largest gradient norms.
        const percentile = 99
        const maxElements = Math.floor(gradientsNorm.size * (1 - percentile/100))
        const maxNorm = tf.topk(gradientsNorm, maxElements, true).values.min()
        // const maxNorm = gradientsNorm.max()
        gradientsNorm.dispose()

        // quantize the gradients by dividing them by maxNorm.
        const gradientsQuantized5 = gradients.div(maxNorm)
        gradients.dispose() 

        // shift the gradients to the range [0, 2].
        const gradientsQuantized4 = gradientsQuantized5.add([1])
        gradientsQuantized5.dispose() 

        // normalize to [0, 1] by dividing by 2.
        const gradientsQuantized3 = gradientsQuantized4.div([2])
        gradientsQuantized4.dispose() 

        // scale the values to the range [0, 255].
        const gradientsQuantized2 = gradientsQuantized3.mul([255])
        gradientsQuantized3.dispose() 

        // round the values to nearest integers.
        const gradientsQuantized1 = gradientsQuantized2.round()
        gradientsQuantized2.dispose() 

        // clip the values to ensure they stay within [0, 255].
        const gradientsQuantized = gradientsQuantized1.clipByValue(0, 255)
        gradientsQuantized1.dispose() 

        // extract the tensor data as an array of 8-bit unsigned integers.
        this.data = new Uint8Array(await gradientsQuantized.data())
        gradientsQuantized.dispose()
        
        // extract the maximum gradient norm
        this.maxNorm = await maxNorm.array()
        maxNorm.dispose()

        return { data: this.data, maxNorm: this.maxNorm}
    }

    dispose()
    {
        this.kernels.dispose()
        this.data = null
        this.maxNorm = null
        this.viewer = null
        this.parameters = null
        this.method = null
    }
}