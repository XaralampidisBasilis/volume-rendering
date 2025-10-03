import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtremaMap, toHalfFloat } from '../Programs/GPGPUExtremaMapFusedPacked'

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
        this.blockSize = this.configs.blockSize
        this.tensor = computeExtremaMap(this.interpolationMap.tensor, this.blockSize)
        const dimensions = this.tensor.shape.slice(0, 3).toReversed()
        this.dimensions = new THREE.Vector3(...dimensions)
        console.timeEnd('computeTensor@ExtremaMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@ExtremaMap') 
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RGBAFormat
        this.texture.type = THREE.HalfFloatType
        this.texture.internalFormat = 'RGBA16F'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 4
        console.timeEnd('computeTexture@ExtremaMap') 
    }   

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData)
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        const tensor = toHalfFloat(this.tensor)
        const dataHalfFloat = new Uint16Array(tensor.dataSync())
        tensor.dispose()
        
        return dataHalfFloat
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
