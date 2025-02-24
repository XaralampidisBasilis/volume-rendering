import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import GUI from './GUI'
import Processor from './Processor'
import { OBB } from "three/addons/math/OBB.js";

export default class MPRViewer extends EventEmitter
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
        this.gui = new GUI(this)
        this.processor = new Processor()
    }
    
    async generateMaps()
    {
        await this.processor.generateIntensityMap()
    }

    async setViewer()
    {
        this.setParameters()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
        this.trigger('ready')
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = { ...this.processor.volume.parameters}
    }

    setTextures()
    {
        this.textures = {}

        // Color maps
        this.textures.colorMaps = this.resources.items.colormaps                      
        this.textures.colorMaps.colorSpace = THREE.SRGBColorSpace
        this.textures.colorMaps.minFilter = THREE.LinearFilter
        this.textures.colorMaps.magFilter = THREE.LinearFilter         
        this.textures.colorMaps.generateMipmaps = false
        this.textures.colorMaps.needsUpdate = true 

        // Intensity map 
        this.textures.intensityMap = new THREE.Data3DTexture(
            this.processor.volume.data, 
            ...this.processor.intensityMap.parameters.dimensions)
        this.textures.intensityMap.format = THREE.RedFormat
        this.textures.intensityMap.type = THREE.FloatType
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.computeMipmaps = false
        this.textures.intensityMap.needsUpdate = true
        tf.dispose(this.processor.intensityMap.tensor)  
    }
  
    setGeometry()
    {
        const size = this.parameters.volume.size
        const offset = this.parameters.volume.size.clone().divideScalar(2)
        this.geometry = new THREE.BoxGeometry(...size)
        this.geometry.translate(...offset) 
    }

    setMaterial()
    {        
        // Computes
        const intensityMap = this.processor.computes.intensityMap

        // Uniforms/Defines
        const u_textures = this.material.uniforms.u_textures.value
        const u_intensity_map = this.material.uniforms.u_intensity_map.value
        const defines = this.material.defines

        // Update Uniforms
        u_textures.intensity_map = this.textures.intensityMap
        u_textures.color_maps = this.textures.colorMaps   
        u_textures.maxima_map = this.textures.maximaMap
        u_textures.distance_map = this.textures.distanceMap
        u_textures.anisotropic_distance_map = this.textures.anisotropicDistanceMap
        
        u_intensity_map.dimensions.copy(intensityMap.parameters.dimensions)
        u_intensity_map.spacing.copy(intensityMap.parameters.spacing)
        u_intensity_map.size.copy(intensityMap.parameters.size)
        u_intensity_map.min_intensity = intensityMap.parameters.minIntensity
        u_intensity_map.max_intensity = intensityMap.parameters.maxIntensity
        u_intensity_map.size_length = intensityMap.parameters.sizeLength
        u_intensity_map.spacing_length = intensityMap.parameters.spacingLength
        u_intensity_map.inv_dimensions.copy(intensityMap.parameters.invDimensions)
        u_intensity_map.inv_spacing.copy(intensityMap.parameters.invSpacing)
        u_intensity_map.inv_size.copy(intensityMap.parameters.invSize)
 

        // Update Defines
        defines.MAX_TRACE_COUNT = Math.ceil(intensityMap.parameters.sizeLength / Math.min(...intensityMap.parameters.spacing))
        defines.MAX_TRACE_SUBCOUNT = Math.ceil(maximaMap.parameters.spacingLength / Math.min(...intensityMap.parameters.spacing))
        defines.MAX_CELL_COUNT = intensityMap.parameters.maxCellCount
        defines.MAX_CELL_SUBCOUNT = 3 * maximaMap.parameters.subDivision - 2
        defines.MAX_BLOCK_COUNT = maximaMap.parameters.maxBlockCount

        // console.log(defines)
    }

    setMesh()
    {   
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).divideScalar(-2)
        this.scene.add(this.mesh)
    }

    destroy() 
    {
        Object.keys(this.textures).forEach(key => 
        {
            if (this.textures[key]) 
            {
                this.textures[key].dispose()
            }
        })
    
        if (this.mesh) 
        {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
        }
    
        // if (this.gui) 
        //     this.gui.destroy()

        if (this.processor)
        {
            this.processor.destroy()
            this.processor = null
        }

        // Clean up references
        this.scene = null
        this.resources = null
        this.renderer = null
        this.camera = null
        this.sizes = null
        this.debug = null
        this.mesh = null
        this.gui = null

        console.log("MPRViewer destroyed")
    }
}