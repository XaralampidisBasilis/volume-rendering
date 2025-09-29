import * as THREE from 'three'
import Configs from './Utils/Configs'
import Debug from './Utils/Debug'
import Sizes from './Utils/Sizes'
import Time from './Utils/Time'
import Mouse from './Utils/Mouse'
import Stats from './Utils/Stats'
import Camera from './Camera'
import Renderer from './Renderer'
import World from './World/World'
import Resources from './Utils/Resources'
import Computes from './Computes/Computes'
import Controls from './Controls'
import sources from './sources'

export default class Experience
{
    static instance = null

    constructor(canvas, context)
    {
        // singleton
        if (Experience.instance) 
        {
            return Experience.instance
        }
        Experience.instance = this
        
        // Global access
        window.experience = this

        // Options
        this.canvas = canvas
        this.context = context

        // Setup
        this.configs = new Configs()
        this.debug = new Debug()
        this.sizes = new Sizes()
        this.time = new Time()
        this.mouse = new Mouse()
        this.scene = new THREE.Scene()
        this.camera = new Camera()
        this.renderer = new Renderer()
        this.resources = new Resources(sources)
        this.computes = new Computes()
        this.world = new World()
        this.controls = new Controls()
        this.stats = new Stats(true)

        // Size resize event
        this.sizes.on('resize', () => 
        {
            this.resize()
        })

        // Time tick event
        this.time.on('tick', () => 
        {
            this.update()
        })

        // Resources ready event
        this.resources.on('ready', () =>
        {
            this.start()
        })

        // Config change event
        this.configs.on('change', (event) =>
        {
            this.change(event)
        })

        // Window refresh event
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
        this.stats.update()    
        this.renderer.update()
    }

    start()
    {
        this.computes.start()
        this.world.start()
        this.controls.start()
    }

    change(event)
    {
        this.computes.change(event)
        this.world.change(event)
    }

    destroy()
    {
        this.sizes.off('resize')
        this.time.off('tick')
        this.configs.off('change')

        // destroy components
        if (this.configs) 
            this.configs.destroy()

        if (this.debug)
            this.debug.destroy()

        if (this.sizes) 
            this.sizes.destroy()

        if (this.time) 
            this.time.destroy()

        if (this.mouse) 
            this.mouse.destroy()

        if (this.world) 
            this.world.destroy()

        if (this.camera)
            this.camera.destroy()

        if (this.renderer) 
            this.renderer.destroy()


        // Nullify properties for cleanup
        this.configs = null
        this.debug = null
        this.sizes = null
        this.time = null
        this.mouse = null
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