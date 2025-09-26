import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Computes from '../Computes'
import { computeResizedMap } from '../Programs/GPGPUResizeMap'
import { computeNormalizedMap } from '../Programs/GPGPUNormalizeMapPacked'
import { computeInterpolationMap, toHalfFloat } from '../Programs/GPGPUInterpolationMapPacked'

export default class InterpolationMap
{
    constructor()
    {
        this.computes = new Computes()
        this.configs = this.computes.configs
        this.resources = this.computes.resources
        this.downscaleFactor = this.configs.downscaleFactor
    }

    setVolume()
    {
        this.volume = this.resources.items.volume
        this.dimensions = new THREE.Vector3().fromArray(this.volume.dimensions)
        this.spacing = new THREE.Vector3().fromArray(this.volume.spacing)
        this.size = new THREE.Vector3().multiplyVectors(this.spacing, this.dimensions)
    }

    compute()
    {
        console.time('computeInterpolationMap') 
        
        this.setVolume()
        const shape = this.volume.dimensions.toReversed()
        const newShape = shape.map((x) => Math.ceil(this.downscaleFactor * x))
        const newSpacing = this.volume.spacing.toReversed().map((x, i) => shape[i]/newShape[i] * x)
        this.dimensions.copy(newShape.toReversed())
        this.spacing.copy(newSpacing.toReversed())

        const volume = tf.tensor3d(new Float32Array(this.volume.data), shape)
        const resizedVolume = computeResizedMap(volume, newShape, false, true); volume.dispose()
        const normalizedVolume = computeNormalizedMap(resizedVolume); resizedVolume.dispose()

        this.tensor = computeInterpolationMap(normalizedVolume); normalizedVolume.dispose() 
        // this.data = this.tensor.dataSync()

        console.timeEnd('computeInterpolationMap') 
    }

    textureSync()
    {
        this.texture = new THREE.Data3DTexture(this.textureDataSync(), ...this.dimensions)
        this.texture.format = THREE.RGBAFormat
        this.texture.type = THREE.HalfFloatType
        this.texture.internalFormat = 'RGBA16F'
        this.texture.minFilter = THREE.LinearFilter
        this.texture.magFilter = THREE.LinearFilter
        this.texture.generateMipmaps = false
        this.texture.needsUpdate = true
        this.texture.unpackAlignment = 4

        return this.texture
    }

    textureDataSync()
    {
        const tensor = toHalfFloat(this.tensor)
        const dataHalfFloat = tensor.dataSync(); tensor.dispose()
        return new Uint16Array(dataHalfFloat.buffer)
    }

    dispose()
    {
        this.tensor?.dispose()
        this.texture?.dispose()
    }
}
