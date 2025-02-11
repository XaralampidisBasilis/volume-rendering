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
        const uMaximaMap = this.material.uniforms.u_maxima_map.value
        await this.processor.generateIntensityMap()
        await this.processor.checkMaximaMap(this.processor.computes.intensityMap.tensor, uMaximaMap.sub_division)
        await this.processor.generateMaximaMap(uMaximaMap.sub_division)
        await this.processor.generateDistanceMap(50)
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

        // Distance map 
        this.textures.distanceMap = new THREE.Data3DTexture(
            this.processor.computes.distanceMap.tensor.dataSync(), 
            ...this.processor.computes.distanceMap.parameters.dimensions)
        this.textures.distanceMap.format = THREE.RedFormat
        this.textures.distanceMap.type = THREE.UnsignedByteType
        this.textures.distanceMap.minFilter = THREE.NearestFilter
        this.textures.distanceMap.magFilter = THREE.NearestFilter
        this.textures.distanceMap.computeMipmaps = false
        this.textures.distanceMap.needsUpdate = true
        tf.dispose(this.processor.computes.distanceMap.tensor)  

        // Maxima map
        this.textures.maximaMap = new THREE.Data3DTexture(
            this.processor.computes.maximaMap.tensor.dataSync(), 
            ...this.processor.computes.maximaMap.parameters.dimensions)
        this.textures.maximaMap.format = THREE.RedFormat
        this.textures.maximaMap.type = THREE.FloatType
        this.textures.maximaMap.minFilter = THREE.NearestFilter
        this.textures.maximaMap.magFilter = THREE.NearestFilter
        this.textures.maximaMap.computeMipmaps = false
        this.textures.maximaMap.needsUpdate = true
        tf.dispose(this.processor.computes.maximaMap.tensor) 
            
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
        // In order to align model vertex coordinates with texture coordinates
        // we translate all with the center, so now they start at zero
        this.geometry.translate(...center) 
    }

    setMaterial()
    {        
        // Computes
        const intensityMap = this.processor.computes.intensityMap
        const maximaMap =  this.processor.computes.maximaMap

        // Uniforms/Defines
        const uTextures = this.material.uniforms.u_textures.value
        const uIntensityMap = this.material.uniforms.u_intensity_map.value
        const uMaximaMap = this.material.uniforms.u_maxima_map.value
        const defines = this.material.defines

        // Update Uniforms
        uTextures.intensity_map = this.textures.intensityMap
        uTextures.maxima_map = this.textures.maximaMap
        uTextures.color_maps = this.textures.colorMaps   

        uIntensityMap.dimensions.copy(intensityMap.parameters.dimensions)
        uIntensityMap.spacing.copy(intensityMap.parameters.spacing)
        uIntensityMap.size.copy(intensityMap.parameters.size)
        uIntensityMap.min_intensity = intensityMap.parameters.minIntensity
        uIntensityMap.max_intensity = intensityMap.parameters.maxIntensity
        uIntensityMap.size_length = intensityMap.parameters.sizeLength
        uIntensityMap.spacing_length = intensityMap.parameters.spacingLength
        uIntensityMap.inv_dimensions.copy(intensityMap.parameters.invDimensions)
        uIntensityMap.inv_spacing.copy(intensityMap.parameters.invSpacing)
        uIntensityMap.inv_size.copy(intensityMap.parameters.invSize)
 
        uMaximaMap.sub_division = maximaMap.parameters.subDivision
        uMaximaMap.dimensions.copy(maximaMap.parameters.dimensions)
        uMaximaMap.spacing.copy(maximaMap.parameters.spacing)
        uMaximaMap.size.copy(maximaMap.parameters.size)
        uMaximaMap.inv_sub_division = maximaMap.parameters.invSubDivision
        uMaximaMap.inv_dimensions.copy(maximaMap.parameters.invDimensions)
        uMaximaMap.inv_spacing.copy(maximaMap.parameters.invSpacing)
        uMaximaMap.inv_size.copy(maximaMap.parameters.invSize)

        // Update Defines
        defines.MAX_CELL_COUNT = intensityMap.parameters.maxCellCount
        defines.MAX_BLOCK_COUNT = maximaMap.parameters.maxBlockCount
        defines.MAX_CELL_SUB_COUNT = 3 * maximaMap.parameters.subDivision - 2
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