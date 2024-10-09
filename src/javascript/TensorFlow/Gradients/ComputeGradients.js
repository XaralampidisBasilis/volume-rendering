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
                throw new Error(`Unknown GRADIENT_METHOD: ${this.method}`)
        }
    }
    

    async compute() 
    {
        tf.tidy(() => 
        {
            // X, Y, Z convolution filters and normalization
            const gradientX1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.x, 1, 'same')
            const gradientX = gradientX1.div([this.parameters.volume.spacing.x])
            gradientX1.dispose()

            const gradientY1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.y, 1, 'same')
            const gradientY = gradientY1.div([this.parameters.volume.spacing.y])
            gradientY1.dispose()

            const gradientZ1 = tf.conv3d(this.viewer.tensors.volume, this.kernels.z, 1, 'same')
            const gradientZ = gradientZ1.div([this.parameters.volume.spacing.z])
            gradientZ1.dispose()

            // Concatenate X, Y, and Z gradients into one tensor
            const gradients = tf.concat([gradientX, gradientY, gradientZ], 3)
            gradientX.dispose(), gradientY.dispose(), gradientZ.dispose() 
    
            // Compute Euclidean norm of the gradients
            const gradientsNorm = tf.norm(gradients, 'euclidean', 3).reshape([-1])
    
            // Find the maximum norm from the top 0.1%
            // const percentile = 99.9 
            // const maxElements = Math.floor(gradientsNorm.size * (1 - percentile / 100))
            // const maxNorm = tf.topk(gradientsNorm, maxElements, true).values.min()
            const maxNorm = gradientsNorm.max()
            gradientsNorm.dispose() 
    
            // Quantize the gradients by dividing by maxNorm
            const gradientsQuantized5 = gradients.div(maxNorm)
            gradients.dispose() 

            // Continue quantization process
            const gradientsQuantized4 = gradientsQuantized5.add([1])
            gradientsQuantized5.dispose()
    
            const gradientsQuantized3 = gradientsQuantized4.div([2])
            gradientsQuantized4.dispose()
    
            const gradientsQuantized2 = gradientsQuantized3.mul([255])
            gradientsQuantized3.dispose()
    
            const gradientsQuantized1 = gradientsQuantized2.round()
            gradientsQuantized2.dispose()
    
            const gradientsQuantized = gradientsQuantized1.clipByValue(0, 255)
            gradientsQuantized1.dispose()
    
            // Extract the tensor data as an array of 8-bit unsigned integers
            this.data = new Uint8Array(gradientsQuantized.dataSync()) 
            gradientsQuantized.dispose()

            this.maxNorm = maxNorm.dataSync() 
            maxNorm.dispose()

            console.log(this.data)
            console.log(this.maxNorm)
            console.log(this.method)
        })

        console.log(tf.memory())

        return { data: this.data, maxNorm: this.maxNorm } 
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