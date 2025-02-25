import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Processor from './Processor'
import Slices from './Slices/Slices'

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

        this.setProcessor().then(() =>
        {
            this.setTextures()
            this.setSlices()
        })
    }

    async setProcessor()
    {
        this.processor = new Processor()

        await this.processor.getReady()
        await this.processor.generateIntensityMap()
        await this.processor.generateBinaryMap()
    }

    setTextures()
    {
        this.textures = {}

        // Color maps
        this.textures.colorMaps = this.resources.items.colorMaps                      
        this.textures.colorMaps.colorSpace = THREE.SRGBColorSpace
        this.textures.colorMaps.minFilter = THREE.LinearFilter
        this.textures.colorMaps.magFilter = THREE.LinearFilter         
        this.textures.colorMaps.generateMipmaps = false
        this.textures.colorMaps.needsUpdate = true 

        // Intensity map 
        this.textures.intensityMap = new THREE.Data3DTexture
        (
            this.processor.intensityMap.tensor.dataSync(), 
            ...this.processor.intensityMap.parameters.dimensions
        )
        this.textures.intensityMap.format = THREE.RedFormat
        tf.dispose(this.processor.intensityMap.tensor)  
        this.textures.intensityMap.type = THREE.FloatType
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.computeMipmaps = false
        this.textures.intensityMap.needsUpdate = true

        // Binary map 
        this.textures.binaryMap = new THREE.Data3DTexture
        (
            this.processor.binaryMap.tensor.dataSync(),
            ...this.processor.binaryMap.parameters.dimensions
        )
        this.textures.binaryMap.format = THREE.RedFormat
        this.textures.binaryMap.type = THREE.UnsignedByteType
        this.textures.binaryMap.minFilter = THREE.NearestFilter
        this.textures.binaryMap.magFilter = THREE.NearestFilter
        this.textures.binaryMap.computeMipmaps = false
        this.textures.binaryMap.needsUpdate = true
        tf.dispose(this.processor.binaryMap.tensor)  
    }

    setSlices()
    {
        this.slices = new Slices()
        this.slices.scale.copy(this.processor.intensityMap.parameters.size)
        this.slices.position.sub(this.processor.intensityMap.parameters.size).divideScalar(2)
        this.slices.children.forEach((slice) => 
        {
            const processor = this.processor
            const uniforms = slice.material.uniforms
            const defines = slice.material.defines

            uniforms.u_textures.value.color_maps = this.textures.colorMaps
            uniforms.u_textures.value.intensity_map = this.textures.intensityMap
            uniforms.u_textures.value.binary_map = this.textures.binaryMap

            uniforms.u_intensity_map.value.dimensions.copy(processor.intensityMap.parameters.dimensions)
            uniforms.u_intensity_map.value.spacing.copy(processor.intensityMap.parameters.spacing)
            uniforms.u_intensity_map.value.size.copy(processor.intensityMap.parameters.size)
            uniforms.u_intensity_map.value.inv_dimensions.copy(processor.intensityMap.parameters.invDimensions)
            uniforms.u_intensity_map.value.inv_spacing.copy(processor.intensityMap.parameters.invSpacing)
            uniforms.u_intensity_map.value.inv_size.copy(processor.intensityMap.parameters.invSize)
            uniforms.u_intensity_map.value.spacing_length = processor.intensityMap.parameters.spacingLength
            uniforms.u_intensity_map.value.size_length = processor.intensityMap.parameters.sizeLength

            uniforms.u_binary_map.value.dimensions.copy(processor.binaryMap.parameters.dimensions)
            uniforms.u_binary_map.value.spacing.copy(processor.binaryMap.parameters.spacing)
            uniforms.u_binary_map.value.size.copy(processor.binaryMap.parameters.size)
            uniforms.u_binary_map.value.inv_dimensions.copy(processor.binaryMap.parameters.invDimensions)
            uniforms.u_binary_map.value.inv_spacing.copy(processor.binaryMap.parameters.invSpacing)
            uniforms.u_binary_map.value.inv_size.copy(processor.binaryMap.parameters.invSize)
            uniforms.u_binary_map.value.spacing_length = processor.binaryMap.parameters.spacingLength
            uniforms.u_binary_map.value.size_length = processor.binaryMap.parameters.sizeLength

            defines.MAX_VOXELS = processor.intensityMap.parameters.maxVoxels

            slice.material.needsUpdate = true
        })

        this.scene.add(this.slices)
        this.camera.instance.position.copy(this.processor.intensityMap.parameters.size).multiplyScalar(5)        
    }

    setGeometry()
    {

    }

    setMaterial()
    {        
        
    }

    setMesh()
    {   
        
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