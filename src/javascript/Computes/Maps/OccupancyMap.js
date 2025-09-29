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
    }

    computeTensor()
    {
        console.time('computeTensor@OccupancyMap') 
        this.dimensions = this.extremaMap.dimensions
        this.isosurfaceValue = this.configs.isosurfaceValue
        this.tensor = computeOccupancyMap(this.extremaMap.tensor, this.isosurfaceValue)
        console.timeEnd('computeTensor@OccupancyMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@OccupancyMap') 
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedByteType
        this.texture.internalFormat = 'R8UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1
        console.timeEnd('computeTexture@OccupancyMap') 
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
