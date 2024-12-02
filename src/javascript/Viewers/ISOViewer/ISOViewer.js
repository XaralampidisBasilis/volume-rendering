import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import VolumeProcessor from '../../Utils/VolumeProcessor'
import ISOMaterial from './ISOMaterial'
import ISOGui from './ISOGui'

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
        this.material = ISOMaterial()
        this.gui = new ISOGui(this)

        this.processor = new VolumeProcessor(this.resources.items.volumeNifti)
        this.precompute().then(() => 
        {
            this.setParameters()
            this.setTextures()
            this.setGeometry()
            this.setMaterial()
            this.setMesh()
            this.trigger('ready')

            console.log(this)
        })
    }
    
    async precompute()
    {
        await this.processor.computeIntensityMap()
        await this.processor.normalizeIntensityMap()
        await this.processor.computeGradientMap()
        await this.processor.computeTaylorMap().then(() => this.processor.gradientMap.tensor.dispose())
        await this.processor.quantizeTaylorMap()
        await this.processor.computeOccupancyBoundingBox(0)
        await this.processor.computeOccupancyDistanceMap(0, 4)
    }

    async updateBoundingBox(threshold)
    {
        await this.processor.computeOccupancyBoundingBox(threshold)
        
        const uVolume = this.material.uniforms.u_volume.value
        const boxParams = this.processor.occupancyBoundingBox.params 
           
        uVolume.min_coords.copy(boxParams.minCoords)
        uVolume.max_coords.copy(boxParams.maxCoords)
        uVolume.min_position.copy(boxParams.minPosition)
        uVolume.max_position.copy(boxParams.maxPosition)      
    }   

    async updateDistmap(threshold, division)
    {
        await this.processor.computeOccupancyDistanceMap(threshold, division)
        
        const uTextures = this.material.uniforms.u_textures.value
        
        uTextures.distmap.dispose()
        uTextures.distmap = this.processor.getTexture('occupancyDistanceMap', THREE.RedFormat, THREE.UnsignedByteType)
        uTextures.distmap.needsUpdate = true
        this.processor.occupancyDistanceMap.tensor.dispose()
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = this.processor.volume.params
    }

    setTextures()
    {
        this.textures = {}

        // taylormap
        this.textures.taylormap = this.processor.getTexture('taylorMap', THREE.RGBAFormat, THREE.UnsignedByteType)
        this.processor.taylorMap.tensor.dispose()
        
        // distmap
        this.textures.distmap = this.processor.getTexture('occupancyDistanceMap', THREE.RedFormat, THREE.UnsignedByteType)
        this.processor.occupancyDistanceMap.tensor.dispose()
        
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
        
        // In order to align model vertex coordinates with texture coordinates
        // we translate all with the center, so now they start at zero
        this.geometry.translate(...center) 
    }

    setMaterial()
    {        
        // parameters
        const volumeParams = this.processor.volume.params
        const taylormapParams = this.processor.taylorMap.params
        const distmapParams =  this.processor.occupancyDistanceMap.params
        const boxParams = this.processor.occupancyBoundingBox.params

        // uniforms
        const uVolume = this.material.uniforms.u_volume.value
        const uDistmap = this.material.uniforms.u_distmap.value
        const uTextures = this.material.uniforms.u_textures.value

        // volume
        uVolume.dimensions.copy(volumeParams.dimensions)
        uVolume.spacing.copy(volumeParams.spacing)
        uVolume.spacing_length = volumeParams.spacing.length()
        uVolume.size.copy(volumeParams.size)
        uVolume.size_length = volumeParams.size.length()
        uVolume.inv_dimensions.copy(volumeParams.invDimensions)
        uVolume.inv_spacing.copy(volumeParams.invSpacing)
        uVolume.inv_spacing_length = volumeParams.invSpacing.length()
        uVolume.inv_size.copy(volumeParams.invSize)
        uVolume.inv_size_length = volumeParams.invSize.length()
        uVolume.min_intensity = taylormapParams.minValue.x
        uVolume.max_intensity = taylormapParams.maxValue.x
        uVolume.min_gradient.fromArray(taylormapParams.minValue.toArray().slice(1))
        uVolume.max_gradient.fromArray(taylormapParams.maxValue.toArray().slice(1))
        uVolume.max_gradient_length = Math.max(uVolume.max_gradient.length(), uVolume.min_gradient.length())
        uVolume.min_coords.copy(boxParams.minCoords)
        uVolume.max_coords.copy(boxParams.maxCoords)
        uVolume.min_position.copy(boxParams.minPosition)
        uVolume.max_position.copy(boxParams.maxPosition)

        // distmap
        uDistmap.division = distmapParams.division
        uDistmap.dimensions.copy(distmapParams.dimensions)
        uDistmap.spacing.copy(distmapParams.spacing)
        uDistmap.size.copy(distmapParams.size)
        uDistmap.inv_dimensions.copy(distmapParams.dimensions.toArray().map(x => 1/x))
        uDistmap.inv_spacing.copy(distmapParams.spacing.toArray().map(x => 1/x))
        uDistmap.inv_size.copy(distmapParams.size.toArray().map(x => 1/x))

        // textures
        uTextures.taylormap = this.textures.taylormap
        uTextures.distmap = this.textures.distmap
        uTextures.colormaps = this.textures.colormaps   
    }

    setMesh()
    {   
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(-0.5)
        this.scene.add(this.mesh)
    }

    destroy() 
    {
    
        Object.keys(this.textures).forEach(key => 
        {
            if (this.textures[key]) 
                this.textures[key].dispose()
        })
    
        if (this.mesh) 
        {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
        }
    
        if (this.gui) 
            this.gui.destroy()

        if (this.processor)
            this.processor.destroy()
    
        // Clean up references
        this.scene = null
        this.resources = null
        this.renderer = null
        this.camera = null
        this.sizes = null
        this.debug = null
        this.mesh = null
        this.gui = null

        console.log("ISOViewer destroyed")
    }
    
}