import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeIsotropicDistanceMap } from '../Programs/GPGPUIsotropicDistanceMapPacked'

export default class IsotropicDistanceMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.occupancyMap = this.computes.occupancyMap
        this.maxDistance = 255
    }

    computeTensor()
    {
        console.time('computeTensor@IsotropicDistanceMap') 
        this.tensor = computeIsotropicDistanceMap(this.occupancyMap.tensor, this.maxDistance)
        this.dimensions = new THREE.Vector3(...this.occupancyMap.dimensions)
        console.timeEnd('computeTensor@IsotropicDistanceMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@IsotropicDistanceMap') 
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedByteType
        this.texture.internalFormat = 'R8UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1
        console.timeEnd('computeTexture@IsotropicDistanceMap') 
    }  

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }
    
    getTextureData()
    {
        return new Uint8Array(this.tensor.dataSync())
    }
    
    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
