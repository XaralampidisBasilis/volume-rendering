import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtendedAnisotropicDistanceMap } from '../Programs/GPGPUExtendedAnisotropicDistanceMapFusedPacked'
import { toHalfFloat, fromHalfFloat } from '../../Utils/DataUtils'

export default class ExtendedAnisotropicDistanceMap 
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
        console.time('computeTensor@ExtendedAnisotropicDistanceMap') 
        this.tensor = computeExtendedAnisotropicDistanceMap(this.occupancyMap.tensor, this.maxDistance)
        this.textureData = this.getTextureData()
        this.dimensions = new THREE.Vector3(...this.occupancyMap.dimensions)
        this.dimensions.z *= 8
        console.timeEnd('computeTensor@ExtendedAnisotropicDistanceMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@ExtendedAnisotropicDistanceMap') 
        this.texture = new THREE.Data3DTexture(this.textureData, ...this.dimensions)
        this.texture.format = THREE.RedIntegerFormat
        this.texture.type = THREE.UnsignedShortType
        this.texture.internalFormat = 'R16UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1
        console.timeEnd('computeTexture@ExtendedAnisotropicDistanceMap') 
    }   

    updateTexture()
    {
        this.texture.image.data.set(this.textureData)
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        const dataFloat = this.tensor.dataSync()
        const dataHalfFloat = new Uint16Array(this.tensor.size)

        for (let i = 0; i < dataFloat.length; ++i) 
        {
            dataHalfFloat[i] = toHalfFloat(dataFloat[i])
        }

        return dataHalfFloat
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
