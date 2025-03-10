

import Gestures from '../Gestures/Gestures'

export default class Transport
{
    constructor(object3D)
    {
        this.gestures = new Gestures()
        this.controller = this.gestures.controller[0]
        this.object3D = object3D

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.point = new THREE.Points()
		this.controller.attach(this.point)
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener('hold', this.listener)
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
        this.controller.remove(this.point)
        this.gestures.removeEventListener('hold', this.listener)
        this.point = null
    }
} 
