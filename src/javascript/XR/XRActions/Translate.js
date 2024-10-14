

import XRGestures from '../XRGestures/XRGestures'

export default class Translate
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
        this.point = new THREE.Points()
		this.gestures.controller[0].attach(this.point)
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
		this.object3D.getWorldPosition(this.point.position)
	}

    onCurrent()
    {
        this.point.getWorldPosition(this.object3D.position)
		this.object3D.parent.worldToLocal(this.object3D.position)
		this.object3D.updateMatrix()
    }

    onEnd()
    {
    }

    destroy() 
    {
        this.gestures.controller[0].remove(this.point)
        this.gestures.removeEventListener(this.gestureEvent, this.listener)
        this.point = null
    }
} 
