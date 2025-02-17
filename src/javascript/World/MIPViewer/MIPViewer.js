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
        const u_maxima_map = this.material.uniforms.u_maxima_map.value
        const u_distance_map = this.material.uniforms.u_distance_map.value
        await this.processor.generateIntensityMap()
        await this.processor.generateMinimaMap(u_maxima_map.sub_division)
        await this.processor.generateMaximaMap(u_maxima_map.sub_division)
        // await this.processor.generateDistanceMap(u_distance_map.max_iterations)
        // await this.processor.generateAnisotropicDistanceMap()
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

        // Anisotropic distance map
        this.textures.anisotropicDistanceMap = new THREE.Data3DTexture(
            new Uint8ClampedArray(this.processor.computes.anisotropicDistanceMap.tensor.dataSync()), 
            ...this.processor.computes.anisotropicDistanceMap.parameters.dimensions)
        this.textures.anisotropicDistanceMap.format = THREE.RGBAFormat
        this.textures.anisotropicDistanceMap.type = THREE.UnsignedByteType
        this.textures.anisotropicDistanceMap.minFilter = THREE.NearestFilter
        this.textures.anisotropicDistanceMap.magFilter = THREE.NearestFilter
        this.textures.anisotropicDistanceMap.computeMipmaps = false
        this.textures.anisotropicDistanceMap.needsUpdate = true
        tf.dispose(this.processor.computes.anisotropicDistanceMap.tensor)

        // Distance map
        this.textures.distanceMap = new THREE.Data3DTexture(
            new Uint8ClampedArray(this.processor.computes.distanceMap.tensor.dataSync()), 
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
        this.geometry.translate(...center) 
    }

    setMaterial()
    {        
        // Computes
        const intensityMap = this.processor.computes.intensityMap
        const maximaMap =  this.processor.computes.maximaMap
        const distanceMap =  this.processor.computes.distanceMap

        // Uniforms/Defines
        const u_textures = this.material.uniforms.u_textures.value
        const u_intensity_map = this.material.uniforms.u_intensity_map.value
        const u_maxima_map = this.material.uniforms.u_maxima_map.value
        const u_distance_map = this.material.uniforms.u_distance_map.value
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
 
        u_maxima_map.sub_division = maximaMap.parameters.subDivision
        u_maxima_map.dimensions.copy(maximaMap.parameters.dimensions)
        u_maxima_map.spacing.copy(maximaMap.parameters.spacing)
        u_maxima_map.size.copy(maximaMap.parameters.size)
        u_maxima_map.inv_sub_division = maximaMap.parameters.invSubDivision
        u_maxima_map.inv_dimensions.copy(maximaMap.parameters.invDimensions)
        u_maxima_map.inv_spacing.copy(maximaMap.parameters.invSpacing)
        u_maxima_map.inv_size.copy(maximaMap.parameters.invSize)

        u_distance_map.dimensions.copy(distanceMap.parameters.dimensions)
        u_distance_map.spacing.copy(distanceMap.parameters.spacing)
        u_distance_map.size.copy(distanceMap.parameters.size)
        u_distance_map.inv_sub_division = distanceMap.parameters.invSubDivision
        u_distance_map.inv_dimensions.copy(distanceMap.parameters.invDimensions)
        u_distance_map.inv_spacing.copy(distanceMap.parameters.invSpacing)
        u_distance_map.inv_size.copy(distanceMap.parameters.invSize)
        u_distance_map.max_distance = distanceMap.parameters.maxDistance

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