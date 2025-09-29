import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtendedIsotropicDistanceMap } from '../Programs/GPGPUExtendedIsotropicDistanceMapPacked'

export default class ExtendedIsotropicDistanceMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.occupancyMap = this.computes.occupancyMap
        this.maxDistance = 31
    }

    computeTensor()
    {
        console.time('computeTensor@ExtendedIsotropicDistanceMap') 
        this.tensor?.dispose()
        this.tensor = computeExtendedIsotropicDistanceMap(this.occupancyMap.tensor, this.maxDistance)
        this.dimensions = this.occupancyMap.dimensions
        console.timeEnd('computeTensor@ExtendedIsotropicDistanceMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@ExtendedIsotropicDistanceMap') 
        this.texture?.dispose()
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedIntType
        this.texture.internalFormat = 'R32UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1
        console.timeEnd('computeTexture@ExtendedIsotropicDistanceMap') 
    }   

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        return new Uint32Array(this.tensor.dataSync())
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
