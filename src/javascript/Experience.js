import * as THREE from 'three'
import Debug from './Utils/Debug'
import Sizes from './Utils/Sizes'
import Time from './Utils/Time'
import Mouse from './Utils/Mouse'
import Keyboard from './Utils/Keyboard'
import Stats from './Utils/Stats'
import Camera from './Camera'
import Renderer from './Renderer'
import World from './World/World'
import Resources from './Utils/Resources'
import sources from './sources'

let instance = null

export default class Experience
{
    constructor(_canvas)
    {
        // Singleton
        if(instance)
        {
            return instance
        }
        instance = this
        
        // Global access
        window.experience = this

        // Options
        this.canvas = _canvas

        // Setup
        this.debug = new Debug()
        this.sizes = new Sizes()
        this.time = new Time()
        this.mouse = new Mouse()
        this.keyboard = new Keyboard()
        this.scene = new THREE.Scene()
        this.camera = new Camera()
        this.resources = new Resources(sources)
        this.renderer = new Renderer()
        this.world = new World()
        this.stats = new Stats(true)

        // Resize event
        this.sizes.on('resize', () => 
        {
            this.resize()
        })

        // Time tick event
        this.time.on('tick', () => 
        {
            this.update()
        })

        // Refresh event
        window.addEventListener('beforeunload', () => 
        {
            this.destroy()
        })
    }

    resize()
    {
        this.camera.resize()
        this.renderer.resize()
    }

    update()
    {
        this.camera.update()

        if (this.renderer.instance.xr.isPresenting)
        {

        }
        else
        {
            this.stats.update()    
            this.renderer.update()
            this.world.update()
        }
    }

    destroy()
    {
        this.sizes.off('resize')
        this.time.off('tick')

        // destroy components
        if (this.mouse) this.mouse.destroy()
        if (this.keyboard) this.keyboard.destroy()
        if (this.world) this.world.destroy()
        if (this.camera) this.camera.destroy()
        if (this.renderer) this.renderer.destroy()
        if (this.debug) this.debug.destroy()

        // Nullify properties for cleanup
        this.debug = null
        this.sizes = null
        this.time = null
        this.mouse = null
        this.keyboard = null
        this.scene = null
        this.camera = null
        this.resources = null
        this.renderer = null
        this.world = null
        this.stats = null
        this.canvas = null

        // Clear the singleton instance
        instance = null

        console.log('Experience destroyed')
    }
}