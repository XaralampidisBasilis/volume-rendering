import * as THREE from 'three'
import Experience from './Experience'

export default class Renderer
{
    constructor()
    {
        this.experience = new Experience()
        this.canvas = this.experience.canvas
        this.sizes = this.experience.sizes
        this.scene = this.experience.scene
        this.camera = this.experience.camera

        this.setInstance()
    }

    setInstance()
    {
        this.instance = new THREE.WebGLRenderer({
            canvas: this.canvas,
            antialias: true,
            depth: true,
            alpha: true,
            sortObjects: false,
            powerPreference: 'high-performance',
            logarithmicDepthBuffer: true,
        })       
        this.instance.setClearColor('#211d20', 1)
        this.instance.setSize(this.sizes.width, this.sizes.height)
        this.instance.setPixelRatio(this.sizes.pixelRatio)
        this.instance.xr.enabled = true;
        this.instance.shadowMap.enabled = false
    }

    resize()
    {
        this.instance.setSize(this.sizes.width, this.sizes.height)
        this.instance.setPixelRatio(this.sizes.pixelRatio)
    }

    update()
    {
        this.instance.render(this.scene, this.camera.instance)
    }

    destroy() 
    {
        if (this.instance) 
        {
            this.instance.dispose()
            this.instance = null // Allow garbage collection
        }

        this.experience = null
        this.canvas = null
        this.sizes = null
        this.scene = null
        this.camera = null

        console.log('Renderer destroyed')
    }
}