import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Processor from './Processor'
import Slices from './Slices/Slices'
import MPRGui from './MPRGui'

export default class MPRViewer extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.canvas = this.experience.canvas
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug
        this.processor = new Processor()

        this.resources.on('ready', () =>
        {
            this.processor.compute()
            this.processor.on('ready', () =>
            {
                this.setTextures()
                this.setSlices()
                this.gui = new MPRGui(this)
            })
        })
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
        this.textures.intensityMap.type = THREE.FloatType
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.computeMipmaps = false
        this.textures.intensityMap.needsUpdate = true
        tf.dispose(this.processor.intensityMap.tensor)  

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
        this.slices = new Slices(this)
        this.slices.position.copy(this.processor.intensityMap.parameters.size).divideScalar(2)
        this.slices.update()

        this.scene.add(this.slices)
        this.camera.instance.position.copy(this.processor.intensityMap.parameters.size).multiplyScalar(2)
    }

    setSurface()
    {
        
    }

    update()
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