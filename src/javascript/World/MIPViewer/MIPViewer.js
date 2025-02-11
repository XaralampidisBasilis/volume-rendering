import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import MIPMaterial from './MIPMaterial'
import MIPGui from './MIPGui'
import MIPProcessor from './MIPProcessor'

export default class MIPViewer extends EventEmitter
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
        this.material = MIPMaterial()
        this.gui = new MIPGui(this)
        this.processor = new MIPProcessor(this.resources.items.volumeNifti)
        this.processor.on('ready', () =>
        {
            this.generateMaps().then(() => this.setViewer())
        })
    }
    
    async generateMaps()
    {
        const u_minima_distance_map = this.material.uniforms.u_minima_distance_map.value
        const u_maxima_distance_map = this.material.uniforms.u_maxima_distance_map.value
        await this.processor.generateIntensityMap()
        await this.processor.generateMinimaDistanceMap(u_minima_distance_map.sub_division, u_minima_distance_map.max_iterations)
        await this.processor.generateMaximaDistanceMap(u_maxima_distance_map.sub_division, u_maxima_distance_map.max_iterations)
        console.log('finished generateMaps')
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

        // Minima distance map
        this.textures.minimaDistanceMap = new THREE.Data3DTexture(
            new Uint8ClampedArray(this.processor.computes.minimaDistanceMap.tensor.dataSync()), 
            ...this.processor.computes.minimaDistanceMap.parameters.dimensions)
        this.textures.minimaDistanceMap.format = THREE.RGFormat
        this.textures.minimaDistanceMap.type = THREE.UnsignedByteType
        this.textures.minimaDistanceMap.minFilter = THREE.NearestFilter
        this.textures.minimaDistanceMap.magFilter = THREE.NearestFilter
        this.textures.minimaDistanceMap.computeMipmaps = false
        this.textures.minimaDistanceMap.needsUpdate = true
        tf.dispose(this.processor.computes.minimaDistanceMap.tensor) 
            
        // Maxima distance map
        this.textures.maximaDistanceMap = new THREE.Data3DTexture(
            new Uint8ClampedArray(this.processor.computes.maximaDistanceMap.tensor.dataSync()), 
            ...this.processor.computes.maximaDistanceMap.parameters.dimensions)
        this.textures.maximaDistanceMap.format = THREE.RGFormat
        this.textures.maximaDistanceMap.type = THREE.UnsignedByteType
        this.textures.maximaDistanceMap.minFilter = THREE.NearestFilter
        this.textures.maximaDistanceMap.magFilter = THREE.NearestFilter
        this.textures.maximaDistanceMap.computeMipmaps = false
        this.textures.maximaDistanceMap.needsUpdate = true
        tf.dispose(this.processor.computes.maximaDistanceMap.tensor) 
            
        // Intensity map 
        this.textures.intensityMap = new THREE.Data3DTexture(
            this.processor.volume.data, 
            ...this.processor.computes.intensityMap.parameters.dimensions)
        this.textures.intensityMap.format = THREE.RedFormat
        this.textures.intensityMap.type = THREE.FloatType
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.computeMipmaps = false
        this.textures.intensityMap.needsUpdate = true
        tf.dispose(this.processor.computes.intensityMap.tensor)  
    }
  
    setGeometry()
    {
        const size = this.parameters.volume.size
        const center = this.parameters.volume.size.clone().divideScalar(2)
        this.geometry = new THREE.BoxGeometry(...size)
        this.geometry.translate(...center) 
    }

    setMaterial()
    {        
        // Computes
        const intensityMap = this.processor.computes.intensityMap
        const minimaDistanceMap =  this.processor.computes.minimaDistanceMap
        const maximaDistanceMap =  this.processor.computes.maximaDistanceMap

        // Uniforms/Defines
        const u_textures = this.material.uniforms.u_textures.value
        const u_intensity_map = this.material.uniforms.u_intensity_map.value
        const u_minima_distance_map = this.material.uniforms.u_minima_distance_map.value
        const u_maxima_distance_map = this.material.uniforms.u_maxima_distance_map.value
        const defines = this.material.defines

        // Update Uniforms
        u_textures.color_maps = this.textures.colorMaps   
        u_textures.minima_distance_map = this.textures.minimaDistanceMap
        u_textures.maxima_distance_map = this.textures.maximaDistanceMap
        u_textures.intensity_map = this.textures.intensityMap
        
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
 
        u_minima_distance_map.sub_division = minimaDistanceMap.parameters.subDivision
        u_minima_distance_map.dimensions.copy(minimaDistanceMap.parameters.dimensions)
        u_minima_distance_map.spacing.copy(minimaDistanceMap.parameters.spacing)
        u_minima_distance_map.size.copy(minimaDistanceMap.parameters.size)
        u_minima_distance_map.inv_sub_division = minimaDistanceMap.parameters.invSubDivision
        u_minima_distance_map.inv_dimensions.copy(minimaDistanceMap.parameters.invDimensions)
        u_minima_distance_map.inv_spacing.copy(minimaDistanceMap.parameters.invSpacing)
        u_minima_distance_map.inv_size.copy(minimaDistanceMap.parameters.invSize)

        u_maxima_distance_map.sub_division = maximaDistanceMap.parameters.subDivision
        u_maxima_distance_map.dimensions.copy(maximaDistanceMap.parameters.dimensions)
        u_maxima_distance_map.spacing.copy(maximaDistanceMap.parameters.spacing)
        u_maxima_distance_map.size.copy(maximaDistanceMap.parameters.size)
        u_maxima_distance_map.inv_sub_division = maximaDistanceMap.parameters.invSubDivision
        u_maxima_distance_map.inv_dimensions.copy(maximaDistanceMap.parameters.invDimensions)
        u_maxima_distance_map.inv_spacing.copy(maximaDistanceMap.parameters.invSpacing)
        u_maxima_distance_map.inv_size.copy(maximaDistanceMap.parameters.invSize)

        // Update Defines
        defines.MAX_CELL_COUNT = intensityMap.parameters.maxCellCount
        defines.MAX_BLOCK_COUNT = minimaDistanceMap.parameters.maxBlockCount
        defines.MAX_CELL_SUB_COUNT = 3 * maximaDistanceMap.parameters.subDivision - 2
        defines.MAX_BATCH_COUNT = Math.ceil(defines.MAX_CELL_COUNT / defines.MAX_CELL_SUB_COUNT)
        defines.MAX_BLOCK_SUB_COUNT = Math.ceil(defines.MAX_BLOCK_COUNT / defines.MAX_BATCH_COUNT)
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

        console.log("MIPViewer destroyed")
    }

    logGPU()
    {
        console.log(`$Tensors = ${tf.memory().numTensors}, Textures = ${this.renderer.instance.info.memory.textures}`)
    }

    logMemory()
    {
        console.log('TensorFlow', tf.memory())
        console.log('WebGLRenderer', this.renderer.instance.info.memory)
    }
    
}