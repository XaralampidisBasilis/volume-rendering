import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Bessel from './Filters/Bessel'
import Gaussian from './Filters/Gaussian'
import Average from './Filters/Average'

// assumes intensity data 3D, and data3DTexture
export default class ComputeSmoothing
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.radius = this.viewer.material.defines.VOLUME_SMOOTHING_RADIUS
        this.method = this.viewer.material.defines.VOLUME_SMOOTHING_METHOD
        this.filter = this.select()
    }

    select() {

        switch (this.method) 
        {
            case 1: return new Bessel(this.radius)
            case 2: return new Gaussian(this.radius)
            case 3: return new Average(this.radius)
            default: throw new Error(`unknown smoothing method: ${this.method}`)
        }
    }

    async compute()
    {   
        console.time('computeSmoothing')
        tf.tidy(() => 
        {
            const smoothed = this.convolute(this.viewer.tensors.volume, this.filter.kernel)
            const quantized = this.quantize(smoothed)
            this.data = new Uint8Array(quantized.dataSync())
        })
        this.dataSync()
        console.timeEnd('computeSmoothing')
    }

    dataSync()
    {
        for (let i = 0; i < this.parameters.volume.count; i++) 
        {
            const i4 = i * 4
            this.viewer.data.volume[i4 + 0] = this.data[i + 0]
        }

        this.viewer.textures.volume.needsUpdate = true
    }

    update()
    {
        this.dispose()
        this.radius = this.viewer.material.defines.VOLUME_SMOOTHING_RADIUS
        this.method = this.viewer.material.defines.VOLUME_SMOOTHING_METHOD
        this.filter = this.select()
    }

    dispose()
    {
        if (this.filter) 
            this.filter.dispose()
    }

    destroy()
    {
        this.filter = null
        this.data = null
        this.viewer = null
        this.radius = null
        this.method = null
        this.parameters = null
    }

    // helper tensor functions

    convolute(tensor, kernel)
    {
        const passX = tf.conv3d(tensor, kernel.separableX, 1, 'same')
        const passY = tf.conv3d(passX, kernel.separableY, 1, 'same') 
        passX.dispose()
        const passZ = tf.conv3d(passY, kernel.separableZ, 1, 'same') 
        passY.dispose()
        return passZ
    }

    quantize(tensor)
    {
        const scaled = tensor.mul([255])
        tensor.dispose()
        const clipped = scaled.clipByValue(0, 255)  
        scaled.dispose()
        const quantized = clipped.round()
        scaled.dispose()
        return quantized
    }
}