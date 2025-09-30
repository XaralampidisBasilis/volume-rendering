import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeInterpolationMap, toHalfFloat } from '../Programs/GPGPUInterpolationMapPacked'
// import { toHalfFloat, fromHalfFloat } from 'three/src/extras/DataUtils.js'

export default class InterpolationMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.volumeMap = this.computes.volumeMap
    }

    computeTensor()
    {
        console.time('computeTensor@InterpolationMap') 
        this.dimensions = this.volumeMap.dimensions
        this.tensor = computeInterpolationMap(this.volumeMap.tensor)
        this.tensorData = this.tensor.dataSync()
        console.timeEnd('computeTensor@InterpolationMap') 
    }

    restoreTensor()
    {
        this.tensor = tf.tensor5d(this.tensorData, this.tensor.shape)
    }

    computeTexture()
    {
        console.time('computeTexture@InterpolationMap') 
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RGBAFormat
        this.texture.type = THREE.HalfFloatType
        this.texture.internalFormat = 'RGBA16F'
        this.texture.minFilter = THREE.LinearFilter
        this.texture.magFilter = THREE.LinearFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 4
        console.timeEnd('computeTexture@InterpolationMap') 
    }

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        const tensor = toHalfFloat(this.tensor)
        const dataHalfFloat = new Uint16Array(tensor.dataSync())
        tensor.dispose()

        return dataHalfFloat
    }

    /*getTextureData()
    {
        const dataFloat = this.tensor.dataSync()
        const dataHalfFloat = new Uint16Array(this.tensor.size)

        for (let i = 0; i < dataFloat.length; ++i) 
        {
            dataHalfFloat[i] = toHalfFloat(dataFloat[i])
        }

        return dataHalfFloat
    }*/

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
