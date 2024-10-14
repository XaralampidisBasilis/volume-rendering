

import XRGestures from '../XRGestures/XRGestures'

export default class Roll
{
    constructor(object3D, gestureEvent)
    {
        this.object3D = object3D
        this.gestureEvent = gestureEvent
        this.gestures = new XRGestures()
        this.setup()
        this.addListener()       
    }

    setup()
    {
        this.angle = 0
		this.axis = new THREE.Vector3()
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener(this.gestureEvent, this.listener)
    }

    onGesture(event)
    {
        if (event.start) this.onStart()
        if (event.current) this.onCurrent()
        if (event.end) this.onEnd()
    }

    onStart()
    {
		this.quaternion0 = this.object3D.quaternion.clone()
	}

    onCurrent()
    {
        this.axis.copy(this.gestures.raycasters.view.ray.direction)
        this.angle = (this.gestures.parametersDual.angleOffset * Math.PI) / 180
		this.angle *= Roll.ANGLE_MULTIPLIER

		this.object3D.quaternion.copy(this.quaternion0)
		this.object3D.rotateOnWorldAxis(this.axis, -this.angle)
    }

    onEnd()
    {
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gestureEvent, this.listener)
        this.gestureEvent = null
        this.angle = null
        this.axis = null
        this.quaternion0 = null
    }
} 

// action constants
Roll.ANGLE_MULTIPLIER = 1.2