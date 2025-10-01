import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeExtendedIsotropicDistanceMap } from '../Programs/GPGPUExtendedIsotropicDistanceMapPacked'
import { toHalfFloat, fromHalfFloat } from '../../Utils/DataUtils'

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
        this.tensor = computeExtendedIsotropicDistanceMap(this.occupancyMap.tensor, this.maxDistance)
        this.textureData = this.getTextureData()
        this.dimensions = new THREE.Vector3(...this.occupancyMap.dimensions)
        console.timeEnd('computeTensor@ExtendedIsotropicDistanceMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@ExtendedIsotropicDistanceMap') 
        this.texture = new THREE.Data3DTexture(this.textureData, ...this.dimensions)
        this.texture.format = THREE.RGIntegerFormat
        this.texture.type = THREE.UnsignedIntType
        this.texture.internalFormat = 'RG16UI'
        this.texture.minFilter = THREE.NearestFilter
        this.texture.magFilter = THREE.NearestFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 2
        console.timeEnd('computeTexture@ExtendedIsotropicDistanceMap') 
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
