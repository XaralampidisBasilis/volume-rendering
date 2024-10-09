import * as THREE from 'three'
import Experience from '../Experience'
import ISOMaterial from './ISOMaterial'
import ISOGui from './ISOGui'
import ComputeGradients from '../TensorFlow/Gradients/ComputeGradients'
import ComputeSmoothing from '../TensorFlow/Smoothing/ComputeSmoothing'
import ComputeBoundingBox from '../TensorFlow/BoundingBox/ComputeBoundingBox'
import ComputeOccupancy from '../Gpgpu/Occupancy/ComputeOccupancy'
import * as tf from '@tensorflow/tfjs'

export default class ISOViewer
{
    constructor()
    {
        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug

        this.setParameters()
        this.setTensors()
        this.setData()
        this.setTextures()
        this.setNoisemaps()
        this.setColormaps()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
        this.processData()

        if (this.debug.active) 
        {
            this.gui = new ISOGui(this)
        } 
    }

    setParameters()
    {
        this.parameters = {}

        // volume parameters
        this.parameters.volume = {
            size         : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.size),
            dimensions   : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.spacing),
            invSize      : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.resources.items.volumeNifti.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.spacing.map((x) => 1 / x)),
            count        : this.resources.items.volumeNifti.dimensions.reduce((product, value) => product * value, 1),
        }

        // mask parameters
        this.parameters.mask = {
            size         : new THREE.Vector3().fromArray(this.resources.items.maskNifti.size),
            dimensions   : new THREE.Vector3().fromArray(this.resources.items.maskNifti.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.resources.items.maskNifti.spacing),
            invSize      : new THREE.Vector3().fromArray(this.resources.items.maskNifti.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.resources.items.maskNifti.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.resources.items.maskNifti.spacing.map((x) => 1 / x)),
        }

        // geometry parameters
        this.parameters.geometry = {
            size  : new THREE.Vector3().fromArray(this.resources.items.volumeNifti.size),
            center: new THREE.Vector3().fromArray(this.resources.items.volumeNifti.size).divideScalar(2),
        }
    }

    setTensors()
    {
        this.tensors = {}

        // volume tensor
        const volumeTensorShape = [ // tensor flow uses the NHWC format by default
            this.resources.items.volumeNifti.dimensions[2], // Batch size (number of images)
            this.resources.items.volumeNifti.dimensions[1], // Height of the image
            this.resources.items.volumeNifti.dimensions[0], // Width of the image
            1,                                              // Number of channels (e.g., RGB channels)
        ]
        this.tensors.volume = tf.tensor4d(this.resources.items.volumeNifti.getData(), volumeTensorShape,'float32')

        // mask tensor
        const maskTensorShape = [ // tensor flow uses the NHWC format by default
            this.resources.items.maskNifti.dimensions[2], // Batch size (number of images)
            this.resources.items.maskNifti.dimensions[1], // Height of the image
            this.resources.items.maskNifti.dimensions[0], // Width of the image
            1,                                            // Number of channels (e.g., RGB channels)
        ]
        this.tensors.mask = tf.tensor4d(this.resources.items.maskNifti.getData(), maskTensorShape,'bool')
    }

    setData()
    {
        this.data = {}

        // volume data
        let dataQuantized = new Uint8ClampedArray(this.tensors.volume.mul(255).round().dataSync())
        this.data.volume = new Uint8ClampedArray(this.parameters.volume.count * 4)
        for (let i = 0; i < this.parameters.volume.count; i++) {
            const i4 = i * 4
            this.data.volume[i4 + 0] = dataQuantized[i]
        }
        dataQuantized = null

        // mask data
        this.data.mask = new Uint8ClampedArray(this.parameters.mask.count * 4)
    }

    setTextures()
    {
        this.textures = {}

        // volume texture
        const volumeDimensions = this.parameters.volume.dimensions.toArray()
        this.textures.volume = new THREE.Data3DTexture(this.data.volume, ...volumeDimensions)
        this.textures.volume.format = THREE.RGBAFormat
        this.textures.volume.type = THREE.UnsignedByteType     
        this.textures.volume.wrapS = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapT = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapR = THREE.ClampToEdgeWrapping
        this.textures.volume.minFilter = THREE.LinearFilter
        this.textures.volume.magFilter = THREE.LinearFilter
        this.textures.volume.generateMipmaps = true
        this.textures.volume.unpackAlignment = 1 
        this.textures.volume.needsUpdate = true   

        // mask texture
        const maskDimensions = this.parameters.mask.dimensions.toArray()
        this.textures.mask = new THREE.Data3DTexture(this.data.mask, ...maskDimensions)
        this.textures.mask.format = THREE.RedFormat
        this.textures.mask.type = THREE.UnsignedByteType     
        this.textures.mask.wrapS = THREE.ClampToEdgeWrapping
        this.textures.mask.wrapT = THREE.ClampToEdgeWrapping
        this.textures.mask.wrapR = THREE.ClampToEdgeWrapping
        this.textures.mask.minFilter = THREE.LinearFilter
        this.textures.mask.magFilter = THREE.LinearFilter
        this.textures.mask.generateMipmaps = true
        this.textures.mask.unpackAlignment = 1   
        this.textures.mask.needsUpdate = true     
    }

    setNoisemaps()
    {
        this.noisemaps = {}        
        this.noisemaps.white256 = this.resources.items.blue256Noisemap
        this.noisemaps.white256.repeat.set(4, 4)
        this.noisemaps.white256.format = THREE.RedFormat
        this.noisemaps.white256.type = THREE.UnsignedByteType
        this.noisemaps.white256.wrapS = THREE.RepeatWrapping
        this.noisemaps.white256.wrapT = THREE.RepeatWrapping
        this.noisemaps.white256.minFilter = THREE.NearestFilter
        this.noisemaps.white256.magFilter = THREE.NearestFilter
        this.noisemaps.white256.generateMipmaps = false
        this.noisemaps.white256.unpackAlignment = 8   
        this.noisemaps.white256.needsUpdate = true         
    }

    setColormaps()
    {        
        this.colormaps = this.resources.items.colormaps                      
        this.colormaps.colorSpace = THREE.SRGBColorSpace
        this.colormaps.minFilter = THREE.LinearFilter
        this.colormaps.magFilter = THREE.LinearFilter         
        this.colormaps.unpackAlignment = 8
        this.colormaps.generateMipmaps = false
        this.colormaps.needsUpdate = true 
    }
  
    setGeometry()
    {
        const geometrySize = this.parameters.geometry.size.toArray()
        const geometryCenter = this.parameters.geometry.center.toArray()
        this.geometry = new THREE.BoxGeometry(...geometrySize)
        this.geometry.translate(...geometryCenter) // to align model and texel coordinates
    }

    setMaterial()
    {
        this.material = new ISOMaterial()

        this.material.uniforms.u_volume.value.dimensions.copy(this.parameters.volume.dimensions)
        this.material.uniforms.u_volume.value.size.copy(this.parameters.volume.size)
        this.material.uniforms.u_volume.value.spacing.copy(this.parameters.volume.spacing)
        this.material.uniforms.u_volume.value.inv_dimensions.copy(this.parameters.volume.invDimensions)
        this.material.uniforms.u_volume.value.inv_size.copy(this.parameters.volume.invSize)
        this.material.uniforms.u_volume.value.inv_spacing.copy(this.parameters.volume.invSpacing)

        this.material.uniforms.u_occupancy.value.box_min.copy(new THREE.Vector3())
        this.material.uniforms.u_occupancy.value.box_max.copy(this.parameters.volume.size)

        this.material.uniforms.u_sampler.value.volume = this.textures.volume
        this.material.uniforms.u_sampler.value.gradients = this.textures.gradients
        this.material.uniforms.u_sampler.value.mask = this.textures.mask
        this.material.uniforms.u_sampler.value.colormap = this.colormaps    
        this.material.uniforms.u_sampler.value.noisemap = this.noisemaps.white256
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(- 0.5)
        this.scene.add(this.mesh)
    }

    async processData()
    {
        console.time('processData')

        // bounding box
        this.computeBoundingBox = new ComputeBoundingBox(this)  
        await this.computeBoundingBox.compute()

            this.material.uniforms.u_occupancy.value.box_min.copy(this.computeBoundingBox.min)
            this.material.uniforms.u_occupancy.value.box_max.copy(this.computeBoundingBox.max) 
            this.computeBoundingBox.dispose()

        // smoothing
        this.computeSmoothing = new ComputeSmoothing(this)  
        await this.computeSmoothing.compute()

            for (let i = 0; i < this.parameters.volume.count; i++) {
                const i4 = i * 4
                this.data.volume[i4 + 0] = this.computeSmoothing.data[i + 0]
            }
            this.computeSmoothing.dispose()

        // gradients
        this.computeGradients = new ComputeGradients(this)  
        await this.computeGradients.compute()

            for (let i = 0; i < this.parameters.volume.count; i++) {
                const i3 = i * 3
                const i4 = i * 4
                this.data.volume[i4 + 1] = this.computeGradients.data[i3 + 0]
                this.data.volume[i4 + 2] = this.computeGradients.data[i3 + 1]
                this.data.volume[i4 + 3] = this.computeGradients.data[i3 + 2]
            }
            this.material.uniforms.u_gradient.value.max_norm = this.computeGradients.maxNorm
            this.computeGradients.dispose()

        
        // dispose
        this.tensors.volume.dispose()
        this.tensors.mask.dispose()
        this.textures.volume.needsUpdate = true

        console.timeEnd('processData')
    }

    update()
    {
    }
}