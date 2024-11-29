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
        this.material = ISOMaterial()
        this.processor = new VolumeProcessor(this.resources.items.volumeNifti)

        this.precompute().then(() => 
        {
            this.setParameters()
            this.setTextures()
            this.setGeometry()
            this.setMaterial()
            this.setMesh()
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
        this.geometry.translate(...center) // align model and texture coordinates
    }

    setMaterial()
    {        
        // parameters
        const paramsVolume = this.processor.parameters.volume
        const paramsTaylormap = this.processor.parameters.taylorMap
        const paramsBox = this.processor.parameters.occupancyBoundingBox
        const paramsDistmap =  this.processor.parameters.occupancyDistanceMap

        // uniforms
        const uVolume = this.material.uniforms.u_volume.value
        const uDistmap = this.material.uniforms.u_distmap.value
        const uTextures = this.material.uniforms.u_textures.value

        // volume
        uVolume.dimensions.copy(paramsVolume.dimensions)
        uVolume.spacing.copy(paramsVolume.spacing)
        uVolume.spacing_length = paramsVolume.spacing.length()
        uVolume.size.copy(paramsVolume.size)
        uVolume.size_length = paramsVolume.size.length()
        uVolume.inv_dimensions.copy(paramsVolume.invDimensions)
        uVolume.inv_spacing.copy(paramsVolume.invSpacing)
        uVolume.inv_spacing_length = paramsVolume.invSpacing.length()
        uVolume.inv_size.copy(paramsVolume.invSize)
        uVolume.inv_size_length = paramsVolume.invSize.length()
        uVolume.min_intensity = paramsTaylormap.minValue.x
        uVolume.max_intensity = paramsTaylormap.maxValue.x
        uVolume.min_gradient.fromArray(paramsTaylormap.minValue.toArray().slice(1))
        uVolume.max_gradient.fromArray(paramsTaylormap.maxValue.toArray().slice(1))
        uVolume.min_position.copy(paramsBox.minPosition)
        uVolume.max_position.copy(paramsBox.maxPosition)

        // distmap
        uDistmap.division = paramsDistmap.division
        uDistmap.dimensions.copy(paramsDistmap.dimensions)
        uDistmap.spacing.copy(paramsDistmap.spacing)
        uDistmap.size.copy(paramsDistmap.size)
        uDistmap.inv_dimensions.copy(paramsDistmap.division.toArray().map(x => 1/x))
        uDistmap.inv_spacing.copy(paramsDistmap.spacing.toArray().map(x => 1/x))
        uDistmap.inv_size.copy(paramsDistmap.size.toArray().map(x => 1/x))

        // textures
        uTextures.taylormap = this.textures.taylormap
        uTextures.distmap = this.textures.distmap
        uTextures.colormaps = this.textures.colormaps    
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(-0.5)
        // this.scene.add(this.mesh)
    }

    destroy() 
    {
    
        // Dispose textures
        if (this.textures.taylormap) {
            this.textures.taylormap.dispose()
            this.textures.taylormap = null
        }
        if (this.textures.distmap) {
            this.textures.distmap.dispose()
            this.textures.distmap = null
        }
        if (this.textures.colormaps) {
            this.textures.colormaps.dispose()
            this.textures.colormaps = null
        }
    
        // Dispose geometry
        if (this.geometry) {
            this.geometry.dispose()
            this.geometry = null
        }
    
        // Remove mesh from the scene
        if (this.mesh) {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
            this.mesh = null
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