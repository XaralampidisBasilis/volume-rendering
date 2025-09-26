import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeOccupancyMap } from '../Programs/GPGPUOccupancyMapPacked'

export default class OccupancyMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.extremaMap = this.computes.extremaMap
        this.isosurfaceValue = this.configs.isosurfaceValue
    }

    compute()
    {
        console.time('computeOccupancyMap') 

        this.tensor = computeOccupancyMap(this.extremaMap.tensor, this.isosurfaceValue)
        this.dimensions = this.extremaMap.dimensions

        console.timeEnd('computeOccupancyMap') 
    }

    textureSync()
    {
        this.texture = new THREE.Data3DTexture(this.textureDataSync(), ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedByteType
        this.texture.internalFormat = 'R8UI'
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
