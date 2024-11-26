import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import ComputeResizing from './TensorFlow/Resizing/ComputeResizing'
import ComputeSmoothing from './TensorFlow/Smoothing/ComputeSmoothing'
import ComputeGradients from './TensorFlow/Gradients/ComputeGradients'
import ComputeExtremap from './TensorFlow/Extremap/ComputeExtremap'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from '../../Utils/TensorUtils'

export default class Data3DVolume extends EventEmitter
{
    constructor(volume)
    {
        super()

        this.volume = volume
        this.setParameters()
        this.setTensor()
    }

    setParameters()
    {
        this.parameters = 
        {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map((x) => 1 / x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            tensorShape  : this.volume.dimensions.toReversed().concat(1), 
        }
    }

    setTensor()
    {
        this.tensor = tf.tensor4d(this.volume.data, this.parameters.tensorShape,'float32')
    }

    setTexture()
    {
        this.textures.volume = new THREE.Data3DTexture(this.tensor.arraySync(), ...this.parameters.dimensions)
        this.textures.volume.format = THREE.RedFormat
        this.textures.volume.type = THREE.UnsignedByteType     
        this.textures.volume.wrapS = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapT = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapR = THREE.ClampToEdgeWrapping
        this.textures.volume.minFilter = THREE.LinearFilter
        this.textures.volume.magFilter = THREE.LinearFilter
        this.textures.volume.generateMipmaps = false
        this.textures.volume.needsUpdate = true   
    }

    gradients()
    {

    }

    quantize()
    {

    }
}