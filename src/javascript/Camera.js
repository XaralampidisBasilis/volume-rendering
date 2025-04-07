import * as THREE from 'three'
import Experience from './Experience'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'

export default class Camera
{
    constructor()
    {
        this.experience = new Experience()
        this.sizes = this.experience.sizes
        this.mouse = this.experience.mouse
        this.scene = this.experience.scene
        this.canvas = this.experience.canvas

        this.setInstance()
        this.setOrbit()
        this.setRaycaster()
    }

    setInstance()
    {
        this.instance = new THREE.PerspectiveCamera(35, this.sizes.width / this.sizes.height, 0.01, 2)
        this.instance.position.set(1, 1, 1)
        this.scene.add(this.instance)
    }

    setOrbit()
    {
        this.orbit = new OrbitControls(this.instance, this.canvas)
        this.orbit.enableDamping = true
        this.orbit.enableZoom = true
        this.orbit.zoomToCursor = true
        this.orbit.zoomSpeed = 2
    }

    setRaycaster()
    {
        this.raycaster = new THREE.Raycaster()
        this.raycaster.setFromCamera(this.mouse.ndcPosition, this.instance)
    }

    resize()
    {
        this.instance.aspect = this.sizes.width / this.sizes.height
        this.instance.updateProjectionMatrix()
    }

    update()
    {
        this.orbit.update()
        this.raycaster.setFromCamera(this.mouse.ndcPosition, this.instance)
    }

    destroy() 
    {
        this.scene.remove(this.instance);

        if (this.orbit) 
        {
            this.orbit.dispose()
            this.orbit = null
        }

        if (this.raycaster)
        {
            this.raycaster = null
        }

        if (this.instance) 
        {
            this.instance = null
        }

        this.experience = null
        this.sizes = null
        this.scene = null
        this.canvas = null

        console.log('Camera destroyed')
    }
}