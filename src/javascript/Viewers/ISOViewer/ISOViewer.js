import * as THREE from 'three'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import VolumeProcessor from '../../Utils/VolumeProcessor'
// import ISOMaterial from './ISOMaterial'
import ISOGui from './ISOGui'
import * as tf from '@tensorflow/tfjs'

export default class ISOViewer extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug
        // this.gui = new ISOGui(this)
        // this.material = ISOMaterial()
        this.processor = new VolumeProcessor(this.resources.items.volumeNifti)

        this.precompute().then(() => 
        {
            this.setParameters()
            this.setTextures()
            this.setGeometry()
            // this.setMaterial()
            // this.setMesh()
            this.trigger('ready')
        })
    }
    async precompute()
    {
        return Promise.allSettled
        ([
            this.processor.computeIntensityMap(),
            this.processor.computeGradientMap(),
            this.processor.normalizeIntensityMap(),
            this.processor.computeTaylorMap(),
            this.processor.quantizeTaylorMap(),
            this.processor.computeOccupancyBoundingBox(0),
            this.processor.computeOccupancyDistanceMap(0, 4, 255),
        ])
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = this.processor.parameters.volume
    }

    setTextures()
    {
        this.textures = {}

        // taylormap
        this.textures.taylormap = this.processor.generateTexture('taylorMap', 'RGBAFormat', 'UnsignedByteType')
        this.processor.computes.taylorMap.dispose()
        
        // distmap
        this.textures.distmap = this.processor.generateTexture('occupancyDistanceMap', 'RedFormat', 'UnsignedByteType')
        this.processor.computes.occupancyDistanceMap.dispose()
        
        // colormaps
        this.textures.colormaps = this.resources.items.colormaps                      
        this.textures.colormaps.colorSpace = THREE.SRGBColorSpace
        this.textures.colormaps.minFilter = THREE.LinearFilter
        this.textures.colormaps.magFilter = THREE.LinearFilter         
        this.textures.colormaps.generateMipmaps = false
        this.textures.colormaps.needsUpdate = true 
    }
  
    setGeometry()
    {
        const size = this.parameters.volume.size
        const center = this.parameters.volume.size.clone().divideScalar(2)
        this.geometry = new THREE.BoxGeometry(...size)
        this.geometry.translate(...center) // to align model and texel coordinates
    }

    setMaterial()
    {        

        // volume
        this.material.uniforms.u_volume.value.dimensions.copy(this.parameters.volume.dimensions)
        this.material.uniforms.u_volume.value.spacing.copy(this.parameters.volume.spacing)
        this.material.uniforms.u_volume.value.spacing_length = this.parameters.volume.spacing.length()
        this.material.uniforms.u_volume.value.size.copy(this.parameters.volume.size)
        this.material.uniforms.u_volume.value.size_length = this.parameters.volume.size.length()
        this.material.uniforms.u_volume.value.inv_dimensions.copy(this.parameters.volume.invDimensions)
        this.material.uniforms.u_volume.value.inv_spacing.copy(this.parameters.volume.invSpacing)
        this.material.uniforms.u_volume.value.inv_spacing_length = this.parameters.volume.invSpacing.length()
        this.material.uniforms.u_volume.value.inv_size.copy(this.parameters.volume.invSize)
        this.material.uniforms.u_volume.value.inv_size_length = this.parameters.volume.invSize.length()
        this.material.uniforms.u_volume.value.min_position.copy(this.processor.parameters.occupancyBoundingBox.minPosition)
        this.material.uniforms.u_volume.value.max_position.copy(this.processor.parameters.occupancyBoundingBox.maxPosition)

        // distmap
        this.material.uniforms.u_distmap.value.division = this.processor.parameters.occupancyDistanceMap.division
        this.material.uniforms.u_distmap.value.dimensions.copy(this.processor.parameters.occupancyDistanceMap.dimensions)
        this.material.uniforms.u_distmap.value.spacing.copy(this.processor.parameters.occupancyDistanceMap.spacing)
        this.material.uniforms.u_distmap.value.size.copy(this.processor.parameters.occupancyDistanceMap.size)
        this.material.uniforms.u_distmap.value.inv_dimensions.copy(this.material.uniforms.u_distmap.value.dimensions.toArray().map(x => 1/x))
        this.material.uniforms.u_distmap.value.inv_spacing.copy(this.material.uniforms.u_distmap.value.spacing.toArray().map(x => 1/x))
        this.material.uniforms.u_distmap.value.inv_size.copy(this.material.uniforms.u_distmap.value.size.toArray().map(x => 1/x))

        // textures
        this.material.uniforms.u_textures.value.taylormap = this.textures.taylormap
        this.material.uniforms.u_textures.value.distmap = this.textures.distmap
        this.material.uniforms.u_textures.value.colormaps = this.textures.colormaps    
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(-0.5)
        // this.scene.add(this.mesh)
    }

    destroy() 
    {
        // Dispose tensors
        if (this.tensors.volume) {
            this.tensors.volume.dispose()
            this.tensors.volume = null
        }
        if (this.tensors.mask) {
            this.tensors.mask.dispose()
            this.tensors.mask = null
        }
    
        // Dispose textures
        if (this.textures.volume) {
            this.textures.volume.dispose()
            this.textures.volume = null
        }
        if (this.textures.mask) {
            this.textures.mask.dispose()
            this.textures.mask = null
        }
    
        // Dispose geometry
        if (this.geometry) {
            this.geometry.dispose()
            this.geometry = null
        }
    
        // Dispose material
        if (this.material) {
            this.material.dispose()
            this.material = null
        }
    
        // Remove mesh from the scene
        if (this.mesh) {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
            this.mesh = null
        }
    
        // Dispose resources associated with bounding box, gradients, and smoothing computations
        if (this.boundingBox) {
            this.boundingBox.destroy()
            this.boundingBox = null
        }
        if (this.gradients) {
            this.gradients.dispose()
            this.gradients.destroy()
            this.gradients = null
        }
        if (this.smoothing) {
            this.smoothing.dispose()
            this.smoothing.destroy()
            this.smoothing = null
        }
    
        // Dispose GUI if it exists
        if (this.gui) {
            this.gui.destroy()
            this.gui = null
        }
    
        // Clean up references
        this.scene = null
        this.resources = null
        this.renderer = null
        this.camera = null
        this.sizes = null
        this.debug = null
    
        console.log("ISOViewer destroyed")
    }
    
}