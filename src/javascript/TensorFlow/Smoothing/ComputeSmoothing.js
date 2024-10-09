import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Bessel from './Kernels/Bessel'
import Gaussian from './Kernels/Gaussian'
import Average from './Kernels/Average'

// assumes intensity data 3D, and data3DTexture
export default class ComputeSmoothing
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.radius = this.viewer.material.defines.SMOOTHING_RADIUS
        this.method = this.viewer.material.defines.SMOOTHING_METHOD
        this.kernels = this.generate()
    }

    generate() {

        switch (this.method) 
        {
            case 1: return new Bessel(this.radius)
            case 2: return new Gaussian(this.radius)
            case 3: return new Average(this.radius)
            default: 
                throw new Error(`Unknown SMOOTHING_METHOD: ${this.method}`)
        }
    }

    async compute()
    {   
        const smoothed3 = this.viewer.tensors.volume.clone()

        // applying the X convolution filter to the volume data.            
        const smoothed2 = tf.conv3d(smoothed3, this.kernels.x, 1, 'same')
        smoothed3.dispose()

        // applying the Y convolution filter to the volume data.
        const smoothed1 = tf.conv3d(smoothed2, this.kernels.y, 1, 'same')
        smoothed2.dispose()

        // applying the Z convolution filter to the volume data.
        const smoothed = tf.conv3d(smoothed1, this.kernels.z, 1, 'same')
        smoothed1.dispose()

        // scale the values to the range [0, 255].
        const smoothedQuantized2 = smoothed.mul([255])
        smoothed.dispose() 

        // round the values to nearest integers.
        const smoothedQuantized1 = smoothedQuantized2.round()
        smoothedQuantized2.dispose() 

        // clip the values to ensure they stay within [0, 255].
        const smoothedQuantized = smoothedQuantized1.clipByValue(0, 255)
        smoothedQuantized1.dispose() 

        // return the final quantized smoothed volumed tensor 
        this.data = new Uint8Array(await smoothedQuantized.data())
        smoothedQuantized.dispose()

        return { data: this.data }
    }

    dispose()
    {
        this.kernels.dispose()
        this.kernels = null
        this.data = null
        this.viewer = null
        this.radius = null
        this.method = null
        this.parameters = null
    }
}