import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtremaMap } from '../Programs/GPGPUExtremaMapFusedPacked'
import { toHalfFloat } from '../Programs/GPGPUToHalfFloatPacked'

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
        
        const shape = this.tensor.shape
        this.dimensions = new THREE.Vector3(...shape.slice(0,3).toReversed())

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
        this.texture.unpackAlignment = 4
        this.texture.needsUpdate = true
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
        const dataFloat = tensor.dataSync()
        const dataHalfFloat = new Uint16Array(dataFloat)
        tensor.dispose()

        return dataHalfFloat
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
