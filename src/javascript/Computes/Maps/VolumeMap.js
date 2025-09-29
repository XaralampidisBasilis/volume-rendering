import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeResizedMap } from '../Programs/GPGPUResizeMap'
import { computeNormalizedMap } from '../Programs/GPGPUNormalizeMapPacked'

export default class VolumeMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.resources = this.computes.resources
    }

    setVolume()
    {
        this.volume = this.resources.items.volume
        this.dimensions = new THREE.Vector3().fromArray(this.volume.dimensions)
        this.spacing = new THREE.Vector3().fromArray(this.volume.spacing)
        this.size = new THREE.Vector3().fromArray(this.volume.size)
    }

    computeTensor()
    {
        console.time('computeTensor@VolumeMap') 
        
        this.setVolume()
        this.downscaleFactor = this.configs.downscaleFactor

        const data = new Float32Array(this.volume.data)
        const shape = this.volume.dimensions.toReversed()
        const newShape = shape.map((x) => Math.ceil(this.downscaleFactor * x))
        const newSpacing = this.volume.spacing.toReversed().map((x, i) => shape[i]/newShape[i] * x)

        this.tensor?.dispose()
        this.tensor = tf.tidy(() =>
        {
            let tensor = tf.tensor3d(data, shape)
            tensor = computeResizedMap(tensor, newShape, false, true)
            tensor = computeNormalizedMap(tensor)
            return tensor
        })
        this.tensorData = this.tensor.dataSync()

        this.dimensions.fromArray(newShape.toReversed())
        this.spacing.fromArray(newSpacing.toReversed())
            
        console.timeEnd('computeTensor@VolumeMap') 
    }

    restoreTensor()
    {
        if (this.tensor.isDisposed)
        {
            this.tensor = tf.tensor5d(this.tensorData, [...this.dimensions, 2, 2])
        }
    }

    computeTexture()
    {
        console.time('computeTexture@VolumeMap') 
        this.texture?.dispose()
        this.texture = new THREE.Data3DTexture(this.getTextureData(), ...this.dimensions)
        this.texture.format = THREE.RedFormat
        this.texture.type = THREE.FloatType
        this.texture.internalFormat = 'R32F'
        this.texture.minFilter = THREE.LinearFilter
        this.texture.magFilter = THREE.LinearFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 1
        console.timeEnd('computeTexture@VolumeMap') 
    }

    updateTexture()
    {
        this.texture.image.data.set(this.getTextureData())
        this.texture.needsUpdate = true
    }

    getTextureData()
    {
        return new Float32Array(this.tensor.dataSync())
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
