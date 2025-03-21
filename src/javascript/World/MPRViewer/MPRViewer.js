import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Computes from './Computes'
import Textures from './Textures'
import Slices from './Slices/Slices'
import Surface from './Surface/Surface'
import Gui from './Gui'

export default class MPRViewer extends EventEmitter
{
    static instance = null

    constructor()
    {
        super()

        // singleton
        if (MPRViewer.instance) 
        {
            return MPRViewer.instance
        }
        MPRViewer.instance = this

        this.experience = new Experience()
        this.canvas = this.experience.canvas
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug
        this.computes = new Computes()
        this.textures = new Textures()

        // Wait for textures
        this.textures.on('ready', () =>
        {
            this.parameters = this.computes.intensityMap.parameters
            this.setGroup()
            this.gui = new Gui()
        })
    }

    setGroup()
    {
        this.group = new THREE.Group()
        this.group.position.copy(this.parameters.size).divideScalar(-2)
        this.camera.instance.position.copy(this.parameters.size).multiplyScalar(2)
        this.scene.add(this.group)

        this.slices = new Slices()
        this.surface = new Surface()
    }

    update()
    {
      
    }

    destroy() 
    {
        if (this.resources)
        {
            this.resources.destroy()
            this.resources = null
        }

        if (this.computes)
        {
            this.computes.destroy()
            this.computes = null
        }

        if (this.textures)
        {
            this.textures.destroy()
            this.textures = null
        }

        if (this.slices)
        {
            this.slices.destroy()
            this.slices = null
        }

        if (this.surface)
        {
            this.surface.destroy()
            this.surface = null
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