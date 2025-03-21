
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

const degToRad = Math.PI / 180

export default class Roll
{
    constructor(object3d,  gesture = 'twist')
    {
        this.xrManager = new XREnvironment()
        this.gestures = this.xrManager.gestures
        this.viewRay = this.gestures.raycasters.view.ray
        this.parameters = this.gestures.parametersDual

        this.object3d = object3d
        this.gesture = gesture
        this.paused = false

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.angle = 0
        this.quaternion = new THREE.Quaternion()
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener(this.gesture, this.listener)
    }

    onGesture(event)
    {
        if (this.paused) return
        if (event.start) this.onStart()
        if (event.current) this.onCurrent()
        if (event.end) this.onEnd()
    }

    onStart()
    {
		this.quaternion.copy(this.object3d.quaternion)
        console.log('roll current', this)
	}

    onCurrent()
    {
        this.angle = - this.parameters.angleOffset * Roll.ANGLE_MULTIPLIER * degToRad

		this.object3d.quaternion.copy(this.quaternion)
		this.object3d.rotateOnWorldAxis(this.viewRay.direction, this.angle)
        console.log('roll current', this)
    }

    onEnd()
    {
        console.log('roll current', this)
    }
      
    pause() 
    {
        if (this.paused) return
        console.log('roll paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('roll resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.object3d = null
        this.angle = null
        this.quaternion = null
    }
} 

// action constants
Roll.ANGLE_MULTIPLIER = 1.2