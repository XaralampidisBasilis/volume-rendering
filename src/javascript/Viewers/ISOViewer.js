import * as THREE from 'three'
import Experience from '../Experience'
import ISOMaterial from './Materials/ISOMaterial'
import ISOGui from './GUI/ISOGui'
import ISOHelpers from './Helpers/ISOHelpers'
import Smoothing from '../Precomputes/Smoothing/Smoothing'
import Gradients from '../Precomputes/Gradients/Gradients'
import ISOOccupancy from '../Precomputes/Occupancy/ISOOccupancy'

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

        this.setParameters()
        this.setNoisemaps()
        this.setColormaps()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()

        this.computeGradients()
        this.computeOccupancy()

        if (this.debug.active) 
        {
            this.gui = new ISOGui(this)
        }       
    }

    setParameters()
    {
        this.parameters = 
        {
            volume: 
            {
                size:       new THREE.Vector3().fromArray(this.resource.volume.size),
                dimensions: new THREE.Vector3().fromArray(this.resource.volume.dimensions),
                spacing:    new THREE.Vector3().fromArray(this.resource.volume.spacing),
                count:      this.resource.volume.dimensions.reduce((product, value) => product * value, 1),
            },

            mask:
            {
                size:       new THREE.Vector3().fromArray(this.resource.mask.size),
                dimensions: new THREE.Vector3().fromArray(this.resource.mask.dimensions),
                spacing:    new THREE.Vector3().fromArray(this.resource.mask.spacing),
            },

            geometry: 
            {
                size:       new THREE.Vector3().fromArray(this.resource.volume.size),
                center:     new THREE.Vector3().fromArray(this.resource.volume.size).divideScalar(2),
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
        this.colormaps.needsUpdate = true 
    }

    setTextures()
    {
        this.textures = {}
        this.setVolumeTexture()
        this.setGradientsTexture()
        this.setMaskTexture()
    }

    setVolumeTexture()
    {
        const volumeData = this.resource.volume.getDataUint8()
        this.textures.volume = new THREE.Data3DTexture(volumeData, ...this.parameters.volume.dimensions.toArray())
        this.textures.volume.format = THREE.RedFormat
        this.textures.volume.type = THREE.UnsignedByteType     
        this.textures.volume.wrapS = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapT = THREE.ClampToEdgeWrapping
        this.textures.volume.wrapR = THREE.ClampToEdgeWrapping
        this.textures.volume.minFilter = THREE.LinearFilter
        this.textures.volume.magFilter = THREE.LinearFilter
        this.textures.volume.needsUpdate = true   
        this.textures.volume.unpackAlignment = 1 
    }

    setGradientsTexture()
    {
        const gradientsData = new Uint8ClampedArray(this.parameters.volume.count * 4)
        this.textures.gradients = new THREE.Data3DTexture(gradientsData, ...this.parameters.volume.dimensions.toArray())
        this.textures.gradients.format = THREE.RGBAFormat
        this.textures.gradients.type = THREE.UnsignedByteType     
        this.textures.gradients.wrapS = THREE.ClampToEdgeWrapping
        this.textures.gradients.wrapT = THREE.ClampToEdgeWrapping
        this.textures.gradients.wrapR = THREE.ClampToEdgeWrapping
        this.textures.gradients.minFilter = THREE.LinearFilter
        this.textures.gradients.magFilter = THREE.LinearFilter
        this.textures.gradients.needsUpdate = true   
        this.textures.gradients.unpackAlignment = 1 
    }

    setMaskTexture()
    {
        const maskData = this.resource.volume.getDataUint8()
        this.textures.mask = new THREE.Data3DTexture(maskData, ...this.parameters.mask.dimensions.toArray())
        this.textures.mask.format = THREE.RedFormat
        this.textures.mask.type = THREE.UnsignedByteType     
        this.textures.mask.wrapS = THREE.ClampToEdgeWrapping
        this.textures.mask.wrapT = THREE.ClampToEdgeWrapping
        this.textures.mask.wrapR = THREE.ClampToEdgeWrapping
        this.textures.mask.minFilter = THREE.LinearFilter
        this.textures.mask.magFilter = THREE.LinearFilter
        this.textures.mask.needsUpdate = true
        this.textures.volume.unpackAlignment = 1   
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
        this.gradients = new Gradients(this)  

        this.textures.gradients.image.data.set(this.gradients.data);
        this.textures.gradients.needsUpdate = true

        // this.gradients.dispose()
    }

    computeOccupancy()
    {
        this.occupancy = new ISOOccupancy(this)

        for (let i = 0; i <  this.occupancy.occumaps.length; i++)
        {
            this.material.uniforms.u_sampler.value.occumaps[i] = this.occupancy.occumaps[i].texture
            this.material.uniforms.u_occupancy.value.dimensions[i] = this.occupancy.occumaps[i].dimensions
            this.material.uniforms.u_occupancy.value.blocks[i] = this.occupancy.occumaps[i].blockDimensions
        }

        this.occupancy.on('ready', () => 
        {
            for (let i = 0; i <  this.occupancy.occumaps.length; i++)
            {
                this.material.uniforms.u_sampler.value.occumaps[i] = this.occupancy.occumaps[i].texture
            }
            this.material.uniforms.u_occupancy.value.box_min = this.occupancy.occubox.min
            this.material.uniforms.u_occupancy.value.box_max = this.occupancy.occubox.max        
        })
    }

    computeSmoothing()
    {
        this.smoothing = new Smoothing(this)

        // update volume texture image data
        for (let i = 0; i < this.parameters.volume.count; i++)
        {
            const i4 = i * 4            
            this.textures.volume.image.data[i4 + 0] = this.smoothing.computation.data[i4 + 0]
            this.textures.volume.image.data[i4 + 1] = this.smoothing.computation.data[i4 + 1]
            this.textures.volume.image.data[i4 + 2] = this.smoothing.computation.data[i4 + 2]
            this.textures.volume.image.data[i4 + 3] = this.smoothing.computation.data[i4 + 3]
        }
        this.textures.volume.needsUpdate = true

        // dispose smoothing
        this.smoothing.dispose()

        /** debug
         
        const coords = new THREE.Vector3()
    
        for (let z = Math.floor(this.parameters.volume.dimensions.z / 2); z < this.parameters.volume.dimensions.z; z++)
        {
            for (let y = Math.floor(this.parameters.volume.dimensions.y / 2); y < this.parameters.volume.dimensions.y; y++)
            {
                for (let x = Math.floor(this.parameters.volume.dimensions.x / 2); x < this.parameters.volume.dimensions.x; x++)
                {
                    let i = vec2ind(this.parameters.volume.dimensions, coords.set(x, y, z))
                    let i4 = i * 4
                    
                    this.textures.volume.image.data[i4 + 0] = this.smoothing.computation.data[i4 + 0]
                    this.textures.volume.image.data[i4 + 1] = this.smoothing.computation.data[i4 + 1]
                    this.textures.volume.image.data[i4 + 2] = this.smoothing.computation.data[i4 + 2]
                    this.textures.volume.image.data[i4 + 3] = this.smoothing.computation.data[i4 + 3]                
                }
            }
        }
        this.textures.volume.needsUpdate = true
        */
    }

    update()
    {
    }
}