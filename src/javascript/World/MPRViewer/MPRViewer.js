import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Computes from './Computes'
import Textures from './Textures'
import MPRSlices from './MPRSlices/MPRSlices'
import MPRSurface from './MPRSurface/MPRSurface'
import Gui from './Gui'

export default class MPRViewer extends THREE.Group
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

        this.textures.on('ready', () =>
        {
            this.parameters = this.computes.intensityMap.parameters
            this.slices = new MPRSlices()
            this.surface = new MPRSurface()
            this.gui = new Gui()

            const size = this.parameters.size
            this.position.copy(size).divideScalar(-2)
            this.camera.instance.position.copy(size).multiplyScalar(2)
            this.scene.add(this)
        })
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

        if (this.computes)
        {
            this.computes.destroy()
            this.computes = null
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