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
        console.time('computeSmoothing')

        tf.tidy(() => 
        {
            // applying the X convolution filter to the volume data. 
            const smoothedX = tf.conv3d(this.viewer.tensors.volume, this.kernels.x, 1, 'same')

            // applying the Y convolution filter to the volume data.
            const smoothedY = tf.conv3d(smoothedX, this.kernels.y, 1, 'same')
            smoothedX.dispose()

            // applying the Z convolution filter to the volume data.
            const smoothedZ = tf.conv3d(smoothedY, this.kernels.z, 1, 'same')
            smoothedY.dispose()

            // scale the values to the range [0, 255].
            const scaled = smoothedZ.mul([255])
            smoothedZ.dispose() 

            // round the values to nearest integers.
            const rounded = scaled.round()
            scaled.dispose() 

            // clip the values to ensure they stay within [0, 255].
            const quantized = rounded .clipByValue(0, 255)
            rounded .dispose() 

            // return the final quantized smoothed volumed tensor 
            this.data = new Uint8Array(quantized.dataSync())
            quantized.dispose()
        })

        console.timeEnd('computeSmoothing')

        return { data: this.data }
    }

    restart()
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.radius = this.viewer.material.defines.SMOOTHING_RADIUS
        this.method = this.viewer.material.defines.SMOOTHING_METHOD
        this.kernels = this.generate()
    }

    update()
    {
        for (let i = 0; i < this.parameters.volume.count; i++) 
        {
            const i4 = i * 4
            this.viewer.data.volume[i4 + 0] = this.data[i + 0]
        }

        this.viewer.textures.volume.needsUpdate = true
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
        console.log(tf.memory())
    }
}