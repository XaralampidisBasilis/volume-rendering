import * as THREE from 'three'
import Experience from './Experience'

/**
 * Renderer
 * 
 * Handles all WebGL rendering using Three.js.
 * Initializes the renderer instance, manages resizing, rendering, and cleanup.
 */
export default class Renderer
{
    constructor()
    {
        this.experience = new Experience()
        this.canvas = this.experience.canvas
        this.context = this.experience.context
        this.sizes = this.experience.sizes
        this.scene = this.experience.scene
        this.camera = this.experience.camera

        this.setInstance()
    }

    setInstance()
    {
        this.instance = new THREE.WebGLRenderer({
            canvas: this.canvas,
            context: this.context,
            antialias: false,
            depth: false,
        })       

        // Set clear color for the background
        this.instance.setClearColor('#211d20', 1)
        // this.instance.setClearColor('#000000', 1)

        // Set renderer size and pixel ratio
        this.instance.setSize(this.sizes.width, this.sizes.height)
        this.instance.setPixelRatio(this.sizes.pixelRatio)

        // Disable shadows if not used
        this.instance.shadowMap.enabled = false
    }

    resize()
    {
        // Update renderer size and pixel ratio on resize
        this.instance.setSize(this.sizes.width, this.sizes.height)
        this.instance.setPixelRatio(this.sizes.pixelRatio)
    }

    update()
    {
        // Render the scene from the camera's perspective
        this.instance.render(this.scene, this.camera.instance)
    }

    destroy() 
    {
        // Dispose of the renderer
        if (this.instance) 
        {
            this.instance.dispose()
            this.instance = null
        }

        // Nullify references for cleanup
        this.experience = null
        this.canvas = null
        this.sizes = null
        this.scene = null
        this.camera = null

        console.log('Renderer destroyed')
    }
}
