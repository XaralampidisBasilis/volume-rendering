import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeInterpolationMap, toHalfFloat } from '../Programs/GPGPUInterpolationMapPacked'

export default class InterpolationMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.volumeMap = this.computes.volumeMap
        this.downscaleFactor = this.configs.downscaleFactor
    }

    computeTensor()
    {
        console.time('computeInterpolationMap') 
    
        this.tensor?.dispose()
        this.tensor = computeInterpolationMap(this.volumeMap.tensor)
        this.tensorData = this.tensor.dataSync()
        this.dimensions = this.volumeMap.dimensions

        console.timeEnd('computeInterpolationMap') 
    }

    restoreTensor()
    {
        if (this.tensor.isDisposed)
        {
            this.tensor = tf.tensor5d(this.tensorData, [...this.dimensions, 2, 2])
        }
    }

    getTexture()
    {
        this.texture?.dispose()
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RGBAFormat
        this.texture.type = THREE.HalfFloatType
        this.texture.internalFormat = 'RGBA16F'
        this.texture.minFilter = THREE.LinearFilter
        this.texture.magFilter = THREE.LinearFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 4

        return this.texture
    }

    getTextureData()
    {
        const tensor = toHalfFloat(this.tensor)
        const dataHalfFloat = tensor.dataSync(); tensor.dispose()
        return new Uint16Array(dataHalfFloat.buffer)
    }

    updateTextureData()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
