

import * as THREE from 'three'
import XRManager from '../XRManager'

export default class Transport
{
    constructor(object3d, gesture = 'hold')
    {
        this.xrManager = new XRManager()
        this.gestures = this.xrManager.gestures
        this.controller = this.gestures.controller[0]

        this.object3d = object3d
        this.gesture = gesture
        this.paused = false
      
        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.point = new THREE.Points()
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
        this.controller.attach(this.point)
		this.object3d.getWorldPosition(this.point.position)
	}

    onCurrent()
    {
        this.point.getWorldPosition(this.object3d.position)
		this.object3d.parent.worldToLocal(this.object3d.position)
		this.object3d.updateMatrix()
    }

    onEnd()
    {
        this.controller.remove(this.point)
    }

    pause() 
    {
        if (this.paused) return
        console.log('parallel translation paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('parallel translation resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.point = null
    }
} 
