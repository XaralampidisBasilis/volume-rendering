import * as THREE from 'three'
import Experience from './Experience'
import { OrientationCube } from './Utils/OrientationCube'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { TrackballControls } from 'three/examples/jsm/controls/TrackballControls'

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
        this.setControls()
        this.setRaycaster()
    }

    setInstance()
    {
        this.instance = new THREE.PerspectiveCamera(35, this.sizes.width / this.sizes.height, 0.01, 2)
        this.instance.position.set(1, 1, 1)
        this.scene.add(this.instance)
    }

    setControls()
    {
        this.controls = {}

        this.controls.orbit = new OrbitControls(this.instance, this.canvas)
        this.controls.orbit.enableDamping = true
        this.controls.orbit.enableZoom = true
        this.controls.orbit.zoomToCursor = true
        this.controls.orbit.zoomSpeed = 2

        // this.controls.trackball = new TrackballControls(this.instance, this.canvas)
        // this.controls.trackball.staticMoving = false
        // this.controls.trackball.dynamicDampingFactor = 0.3
        // this.controls.trackball.zoomSpeed = 2.0
        // this.controls.trackball.panSpeed = 0.05
        // this.controls.trackball.rotateSpeed = 1.0
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
        // let distance = Math.max(this.instance.position.distanceTo( this.controls.trackball.target), 0.0001)
        // this.controls.trackball.panSpeed  = 0.05 / distance
        // this.controls.trackball.zoomSpeed = 0.5 / distance
        // this.controls.trackball.update()

        this.controls.orbit.update()
        this.raycaster.setFromCamera(this.mouse.ndcPosition, this.instance)
    }

    destroy() 
    {
        this.scene.remove(this.instance);

        if (this.controls.obit) 
        {
            this.controls.obit.dispose()
            this.controls = null
        }
        
        if (this.controls.trackball) 
        {
            this.controls.trackball.dispose()
            this.controls = null
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