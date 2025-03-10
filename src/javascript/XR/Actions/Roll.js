

import Gestures from '../Gestures/Gestures'

const degToRad = Math.PI / 180

export default class Roll
{
    constructor(object3D)
    {
        this.object3D = object3D
        this.gestures = new Gestures()
        this.viewRay = this.gestures.raycasters.view.ray
        this.parameters = this.gestures.parametersDual

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.angle = 0
		this.axis = new THREE.Vector3()
        this.quaternion = new THREE.Quaternion()
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener('twist', this.listener)
    }

    onGesture(event)
    {
        if (event.start) this.onStart()
        if (event.current) this.onCurrent()
        if (event.end) this.onEnd()
    }

    onStart()
    {
		this.quaternion.copy(this.object3D.quaternion)
	}

    onCurrent()
    {
        this.axis.copy(this.viewRay.direction)
        this.angle = this.parameters.angleOffset * degToRad
		this.angle *= Roll.ANGLE_MULTIPLIER

		this.object3D.quaternion.copy(this.quaternion)
		this.object3D.rotateOnWorldAxis(this.axis, -this.angle)
    }

    onEnd()
    {

    }

    destroy() 
    {
        this.gestures.removeEventListener('twist', this.listener)
        this.angle = null
        this.axis = null
        this.quaternion = null
    }
} 

// action constants
Roll.ANGLE_MULTIPLIER = 1.2