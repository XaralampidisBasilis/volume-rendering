import * as THREE from 'three'
import Experience from '../Experience'
import ISOMaterial from './ISOMaterial'
import ISOGui from './ISOGui'
import ISOHelpers from './ISOHelpers'
import ComputeSmoothing from '../Gpgpu/Smoothing/ComputeSmoothing'
import ComputeGradients from '../Gpgpu/Gradients/ComputeGradients'
import ComputeOccupancy from '../Gpgpu/Occupancy/ComputeOccupancy'
import 'https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@latest'

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

        // Resource
        this.resource = {}        
        this.resource.volume = this.resources.items.volumeNifti
        this.resource.mask = this.resources.items.maskNifti  
        // this.processResources()

        this.setParameters()
        this.setNoisemaps()
        this.setColormaps()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()

        this.computeGradients()
        this.computeSmoothing()
        this.computeOccupancy()

        if (this.debug.active) 
        {
            this.gui = new ISOGui(this)
        } 
    }

    processResources()
    {
        const volumeData = this.resource.volume.getData()
        const volumeDimensions = this.resource.volume.dimensions
        const maxVolumeTexels = this.renderer.instance.capabilities.maxTextureSize ** 2
        const maxImagePixels = maxVolumeTexels / volumeDimensions[2]
        const aspectRatio = volumeDimensions[0] / volumeDimensions[1];
        const imageWidth  = Math.min(Math.floor(Math.sqrt(    aspectRatio * maxImagePixels)), volumeDimensions[0]);
        const imageHeight = Math.min(Math.floor(Math.sqrt(1 / aspectRatio * maxImagePixels)), volumeDimensions[1]);

        this.volumeTensor = tf.tensor(volumeData, volumeDimensions, 'float32') 
        this.volumeTensor.resizeBilinear([imageWidth, imageHeight], false, true)
    }


    setParameters()
    {
        this.parameters = 
        {
            volume: 
            {
                size         : new THREE.Vector3().fromArray(this.resource.volume.size),
                dimensions   : new THREE.Vector3().fromArray(this.resource.volume.dimensions),
                spacing      : new THREE.Vector3().fromArray(this.resource.volume.spacing),
                spacing      : new THREE.Vector3().fromArray(this.resource.volume.spacing),
                invSize      : new THREE.Vector3().fromArray(this.resource.volume.size.map((x) => 1 / x)),
                invDimensions: new THREE.Vector3().fromArray(this.resource.volume.dimensions.map((x) => 1 / x)),
                invSpacing   : new THREE.Vector3().fromArray(this.resource.volume.spacing.map((x) => 1 / x)),
                count        : this.resource.volume.dimensions.reduce((product, value) => product * value, 1),
            },

            mask:
            {
                size         : new THREE.Vector3().fromArray(this.resource.mask.size),
                dimensions   : new THREE.Vector3().fromArray(this.resource.mask.dimensions),
                spacing      : new THREE.Vector3().fromArray(this.resource.mask.spacing),
                invSize      : new THREE.Vector3().fromArray(this.resource.mask.size.map((x) => 1 / x)),
                invDimensions: new THREE.Vector3().fromArray(this.resource.mask.dimensions.map((x) => 1 / x)),
                invSpacing   : new THREE.Vector3().fromArray(this.resource.mask.spacing.map((x) => 1 / x)),
            },

            geometry: 
            {
                size  : new THREE.Vector3().fromArray(this.resource.volume.size),
                center: new THREE.Vector3().fromArray(this.resource.volume.size).divideScalar(2),
            }
        }
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

    setTextures()
    {
        this.textures = {}
        this.setSourceTexture()
        this.setVolumeTexture()
        this.setMaskTexture()
    }

    setSourceTexture()
    {
        const volumeDimensions = this.parameters.volume.dimensions.toArray()
        const volumeData = this.resource.volume.getData()
        this.textures.source = new THREE.Data3DTexture(volumeData, ...volumeDimensions)
        this.textures.source.format = THREE.RedFormat
        this.textures.source.type = THREE.FloatType     
        this.textures.source.wrapS = THREE.ClampToEdgeWrapping
        this.textures.source.wrapT = THREE.ClampToEdgeWrapping
        this.textures.source.wrapR = THREE.ClampToEdgeWrapping
        this.textures.source.minFilter = THREE.LinearFilter
        this.textures.source.magFilter = THREE.LinearFilter
        this.textures.source.generateMipmaps = false
        this.textures.source.unpackAlignment = 1 
        this.textures.source.needsUpdate = true   
    }

    setVolumeTexture()
    {
        const volumeData = this.resource.volume.getDataUint8()
        const volumeData4 = new Uint8ClampedArray(this.parameters.volume.count * 4)
        for (let i = 0; i < this.parameters.volume.count; i++)
        {
            const i4 = i * 4
            volumeData4[i4 + 0] = volumeData[i]
        }

        const volumeDimensions = this.parameters.volume.dimensions.toArray()
        this.textures.volume = new THREE.Data3DTexture(volumeData4, ...volumeDimensions)
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
    }

    setMaskTexture()
    {
        const maskData = this.resource.volume.getDataUint8()
        const maskDimensions = this.parameters.mask.dimensions.toArray()
        this.textures.mask = new THREE.Data3DTexture(maskData, ...maskDimensions)
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

    computeGradients()
    {
        this.gradients = new ComputeGradients(this)  

        for (let i = 0; i < this.parameters.volume.count; i++)
        {
            const i4 = i * 4
            this.textures.volume.image.data[i4 + 1] = this.gradients.data[i4 + 0]
            this.textures.volume.image.data[i4 + 2] = this.gradients.data[i4 + 1]
            this.textures.volume.image.data[i4 + 3] = this.gradients.data[i4 + 2]
        }
        this.textures.volume.needsUpdate = true
        this.material.uniforms.u_gradient.value.max_norm = this.gradients.maxNorm
        this.gradients.data = null;
    }

    computeSmoothing()
    {
        this.smoothing = new ComputeSmoothing(this)

        for (let i = 0; i < this.parameters.volume.count; i++)
        {
            const i4 = i * 4
            this.textures.volume.image.data[i4 + 0] = this.smoothing.data[i4 + 0]
        }
        this.textures.volume.needsUpdate = true
        this.smoothing.data = null;
    }

    computeOccupancy()
    {
        this.occupancy = new ComputeOccupancy(this)
        this.material.uniforms.u_sampler.value.occumap = this.occupancy.occumap
        this.material.uniforms.u_occupancy.value.occumap_dimensions.copy(this.occupancy.parameters.occumapDimensions)
        this.material.uniforms.u_occupancy.value.block_dimensions.copy(this.occupancy.parameters.blockDimensions)
        this.material.uniforms.u_occupancy.value.box_min.copy(this.occupancy.occubox.min)
        this.material.uniforms.u_occupancy.value.box_max.copy(this.occupancy.occubox.max)        
    }

    update()
    {
    }
}