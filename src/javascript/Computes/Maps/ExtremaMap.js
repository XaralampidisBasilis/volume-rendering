import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtremaMap, toHalfFloat } from '../Programs/GPGPUExtremaMapPacked'

export default class ExtremaMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.interpolationMap = this.computes.interpolationMap
    }

    computeTensor()
    {
        console.time('computeTensor@ExtremaMap') 

        this.interpolationMethod = this.configs.interpolationMethod
        this.blockSize = this.configs.blockSize

        this.tensor?.dispose()
        this.tensor = computeExtremaMap(this.interpolationMap.tensor, this.interpolationMethod, this.blockSize)
        
        const dimensions = this.tensor.shape.slice(0, 3).toReversed()
        this.dimensions = new THREE.Vector3().fromArray(dimensions)

        console.timeEnd('computeTensor@ExtremaMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@ExtremaMap') 
        this.texture?.dispose()
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RGFormat
        this.texture.type = THREE.HalfFloatType
        this.texture.internalFormat = 'RG16F'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 2
        console.timeEnd('computeTexture@ExtremaMap') 
    }   

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        const tensor = toHalfFloat(this.tensor)
        const dataHalfFloat = tensor.dataSync(); tensor.dispose()
        return new Uint16Array(dataHalfFloat.buffer)
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
