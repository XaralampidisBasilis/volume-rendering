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

    compute()
    {
        console.time('computeExtendedIsotropicDistanceMap') 

        this.tensor = computeExtendedIsotropicDistanceMap(this.occupancyMap.tensor, this.maxDistance)
        this.dimensions = this.occupancyMap.dimensions

        console.timeEnd('computeExtendedIsotropicDistanceMap') 
    }

    textureSync()
    {
        this.texture = new THREE.Data3DTexture(this.textureDataSync(), ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedIntType
        this.texture.internalFormat = 'R32UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1

        return this.texture
    }   

    textureDataSync()
    {
        return new Uint8Array(this.tensor.dataSync())
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
