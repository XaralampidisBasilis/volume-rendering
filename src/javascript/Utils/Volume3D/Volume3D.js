import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from '../TensorUtils'
import EventEmitter from '../EventEmitter'
import timeit from '../timeit'


export default class Volume3D extends EventEmitter
{
    constructor(volume)
    {
        super()

        this.volume = volume
        this.setParameters()
        this.setTensors()
        this.setTextures()

        // timeit(() => this.computeGradients(), 'computeGradients')
        // timeit(() => this.computeOccupancymap(), 'computeOccupancymap')
        timeit(() => this.computeOccupancyatlas(), 'computeOccupancyatlas')
        // timeit(() => this.computeDistancemap(), 'computeDistancemap')
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = 
        {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map((x) => 1 / x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            tensorShape  : this.volume.dimensions.toReversed().concat(1).concat(1), 
        }
    }

    setTensors()
    {
        this.tensors = {}
        this.tensors.volume = tf.tensor5d(this.volume.data, this.parameters.volume.tensorShape,'float32')
    }

    setTextures()
    {
        this.textures = {}
        this.textures.volume = new THREE.Data3DTexture(this.tensors.volume.data(), ...this.parameters.volume.dimensions)
        this.textures.volume.format = THREE.RedFormat
        this.textures.volume.type = THREE.FloatType     
        this.textures.volume.wrapS = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapT = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapR = THREE.ClampToEdgeWrapping
        this.textures.volume.minFilter = THREE.LinearFilter
        this.textures.volume.magFilter = THREE.LinearFilter
        this.textures.volume.generateMipmaps = false
        this.textures.volume.needsUpdate = true   
    }
    
    computeGradients()
    {
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)
        this.textures.gradients = new THREE.Data3DTexture(this.tensors.gradients.data(), ...this.parameters.volume.dimensions)
        this.textures.gradients.format = THREE.RGBFormat
        this.textures.gradients.type = THREE.FloatType     
        this.textures.gradients.wrapS = THREE.ClampToEdgeWrapping
        this.textures.gradients.wrapT = THREE.ClampToEdgeWrapping
        this.textures.gradients.wrapR = THREE.ClampToEdgeWrapping
        this.textures.gradients.minFilter = THREE.LinearFilter
        this.textures.gradients.magFilter = THREE.LinearFilter
        this.textures.gradients.generateMipmaps = false
        this.textures.gradients.needsUpdate = true   
    }

    computeOccupancymap()
    {
        this.tensors.occupancymap = TensorUtils.occupancymap(this.tensors.volume, 2)
        this.textures.occupancymap = new THREE.Data3DTexture(this.tensors.occupancymap.data(), ...this.parameters.volume.dimensions)
        this.textures.occupancymap.format = THREE.RedFormat
        this.textures.occupancymap.type = THREE.UnsignedByteType     
        this.textures.occupancymap.wrapS = THREE.ClampToEdgeWrapping
        this.textures.occupancymap.wrapT = THREE.ClampToEdgeWrapping
        this.textures.occupancymap.wrapR = THREE.ClampToEdgeWrapping
        this.textures.occupancymap.minFilter = THREE.LinearFilter
        this.textures.occupancymap.magFilter = THREE.LinearFilter
        this.textures.occupancymap.generateMipmaps = false
        this.textures.occupancymap.needsUpdate = true   
    }

    computeOccupancyatlas()
    {
        this.tensors.occupancyatlas = TensorUtils.occupancyatlas(this.tensors.volume, 2)
        this.textures.occupancyatlas = new THREE.Data3DTexture(this.tensors.occupancyatlas.data(), ...this.parameters.volume.dimensions)
        this.textures.occupancyatlas.format = THREE.RedFormat
        this.textures.occupancyatlas.type = THREE.UnsignedByteType     
        this.textures.occupancyatlas.wrapS = THREE.ClampToEdgeWrapping
        this.textures.occupancyatlas.wrapT = THREE.ClampToEdgeWrapping
        this.textures.occupancyatlas.wrapR = THREE.ClampToEdgeWrapping
        this.textures.occupancyatlas.minFilter = THREE.LinearFilter
        this.textures.occupancyatlas.magFilter = THREE.LinearFilter
        this.textures.occupancyatlas.generateMipmaps = false
        this.textures.occupancyatlas.needsUpdate = true   
    }

    computeExtremamap()
    {
        this.tensors.extremamap = TensorUtils.extremamap(this.tensors.volume, 2)
        this.textures.extremamap = new THREE.Data3DTexture(this.tensors.extremamap.data(), ...this.parameters.volume.dimensions)
        this.textures.extremamap.format = THREE.RGFormat
        this.textures.extremamap.type = THREE.FloatType     
        this.textures.extremamap.wrapS = THREE.ClampToEdgeWrapping
        this.textures.extremamap.wrapT = THREE.ClampToEdgeWrapping
        this.textures.extremamap.wrapR = THREE.ClampToEdgeWrapping
        this.textures.extremamap.minFilter = THREE.LinearFilter
        this.textures.extremamap.magFilter = THREE.LinearFilter
        this.textures.extremamap.generateMipmaps = false
        this.textures.extremamap.needsUpdate = true   
    }

    computeDistancemap()
    {
        this.tensors.occupancymap = TensorUtils.occupancymap(this.tensors.volume, 2)
        this.tensors.distancemap = TensorUtils.distancemap(this.tensors.occupancymap, 255)
        this.textures.distancemap = new THREE.Data3DTexture(this.tensors.distancemap.data(), ...this.parameters.volume.dimensions)
        this.textures.distancemap.format = THREE.RedFormat
        this.textures.distancemap.type = THREE.UnsignedByteType     
        this.textures.distancemap.wrapS = THREE.ClampToEdgeWrapping
        this.textures.distancemap.wrapT = THREE.ClampToEdgeWrapping
        this.textures.distancemap.wrapR = THREE.ClampToEdgeWrapping
        this.textures.distancemap.minFilter = THREE.LinearFilter
        this.textures.distancemap.magFilter = THREE.LinearFilter
        this.textures.distancemap.generateMipmaps = false
        this.textures.distancemap.needsUpdate = true   

        console.log(this.tensors.occupancymap.dataSync())
        console.log(this.tensors.distancemap.dataSync())
    }
}