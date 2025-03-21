
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class ParallelTransport
{
    constructor(object3d, gesture = 'hold')
    {
        this.xrManager = new XREnvironment()
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
        this.transporter = new THREE.Object3D()
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
        this.object3d.updateMatrixWorld(true)
        this.object3d.getWorldPosition(this.transporter.position)
        this.controller.attach(this.transporter)
        console.log('parallel transport start', this)
	}

    onCurrent()
    {
        this.transporter.getWorldPosition(this.object3d.position)
		this.object3d.parent.worldToLocal(this.object3d.position)
        this.object3d.updateMatrixWorld(true)
        console.log('parallel transport current', this)
    }

    onEnd()
    {
        this.controller.remove(this.transporter)
        console.log('parallel transport end', this)
    }

    pause() 
    {
        if (this.paused) return
        console.log('parallel transport paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('parallel transport resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.transporter = null
    }
} 
