import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Scharr from './Kernels/Scharr'
import Sobel from './Kernels/Sobel'
import Central from './Kernels/Central'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradientsTF
{   
    constructor(viewer)
    { 

        this.viewer = viewer
        this.parameters = this.viewer.parameters

        this.startTime()
        this.setKernels()
        this.compute()
        this.dispose()
        this.endTime()
        
    }

    setKernels()
    {
        this.kernels = new Central()
    }

    compute()
    {   
        [this.tensor, this.maxNorm] = tf.tidy(() => 
        {    
            // applying the X convolution filter to the volume data.
            const filterX = this.kernels.x.expandDims(-1).expandDims(-1)
            const gradientX1 = tf.conv3d(this.viewer.tensors.volume, filterX, 1, 'same')
            filterX.dispose() 
    
            // normalize the gradient along X by dividing by the voxel spacing in X direction.
            const gradientX = gradientX1.div([this.parameters.volume.spacing.x])
            gradientX1.dispose() 
    
            // applying the Y convolution filter to the volume data.
            const filterY = this.kernels.y.expandDims(-1).expandDims(-1)
            const gradientY1 = tf.conv3d(this.viewer.tensors.volume, filterY, 1, 'same')
            filterY.dispose() 
    
            // normalize the gradient along Y by dividing by the voxel spacing in Y direction.
            const gradientY = gradientY1.div([this.parameters.volume.spacing.y])
            gradientY1.dispose() 
    
            // applying the Z convolution filter to the volume data.
            const filterZ = this.kernels.z.expandDims(-1).expandDims(-1)
            const gradientZ1 = tf.conv3d(this.viewer.tensors.volume, filterZ, 1, 'same')
            filterZ.dispose() 
    
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

            // find the smallest element among the top 0.1% (0.001) of the largest gradient norms.
            const percentile = 99.9
            const maxElements = Math.floor(gradientsNorm.size * (1 - percentile/100))
            // const maxNorm = tf.topk(gradientsNorm, maxElements, true).values.min() // gradientsNorm.max()
            const maxNorm = gradientsNorm.max()
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
    
            // return the final quantized gradient tensor and the maximum gradient norm.
            return [gradientsQuantized.transpose([0, 1, 2, 3]), maxNorm]
        })
    
        // extract the tensor data as an array of 8-bit unsigned integers.
        this.data = new Uint8Array(this.tensor.dataSync())
        
        // extract the maximum gradient norm value.
        this.maxNorm = this.maxNorm.dataSync()
        
        // log the data and maximum norm for debugging purposes.
        console.log(this.data)
        console.log(this.maxNorm)
    }

    dispose()
    {
        this.kernels.dispose()
        this.tensor.dispose()
    }

    startTime()
    {
        console.time('compute gradients')
    }

    endTime()
    {
        console.timeEnd('compute gradients')
    }

}