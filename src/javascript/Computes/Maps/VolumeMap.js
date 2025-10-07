import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { resizeTrilinear } from '../Programs/GPGPUResizeTrilinear'
import { normalize } from '../Programs/GPGPUNormalizePacked'

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

        const shape = this.volume.dimensions.toReversed()
        const newShape = shape.map((x) => Math.ceil(this.downscaleFactor * x))
        const newSpacing = this.volume.spacing.toReversed().map((x, i) => shape[i]/newShape[i] * x)
        
        this.dimensions.fromArray(newShape.toReversed())
        this.spacing.fromArray(newSpacing.toReversed())
        this.tensor = tf.tidy(() =>
        {
            let data = new Float32Array(this.volume.data)
            let tensor = tf.tensor3d(data, shape)
            tensor = resizeTrilinear(tensor, newShape, false, true)
            tensor = normalize(tensor)
            return tensor
        })  
        console.timeEnd('computeTensor@VolumeMap') 
    }

    computeTexture()
    {
        console.time('computeTexture@VolumeMap') 
        this.texture = new THREE.Data3DTexture(this.getTextureData, ...this.dimensions)
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
