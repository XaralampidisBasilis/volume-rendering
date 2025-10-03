import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeOccupancyMap } from '../Programs/GPGPUOccupancyMapPacked'
import { computeBoundingBox as getBoundingBox } from '../Programs/GPGPUBoundingBox'

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
        this.isosurfaceValue = this.configs.isosurfaceValue
        this.interpolationMethod = this.configs.interpolationMethod
        this.tensor = computeOccupancyMap(this.extremaMap.tensor, this.interpolationMethod, this.isosurfaceValue)
        this.dimensions = this.extremaMap.dimensions
        console.timeEnd('computeTensor@OccupancyMap') 
    }

    computeBoundingBox()
    {
        console.time('computeBoundingBox@OccupancyMap') 
        this.boundingBox = getBoundingBox(this.tensor)
        console.timeEnd('computeBoundingBox@OccupancyMap') 
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
        this.texture.unpackAlignment = 1
        this.texture.needsUpdate = true
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
