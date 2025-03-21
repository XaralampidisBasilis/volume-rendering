
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class Grab
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
		this.grip = new THREE.Object3D()
        this.transform = new THREE.Matrix4()
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
        // copy world transformations of object to grip
        this.object3d.matrixWorld.decompose(this.grip.position, this.grip.quaternion, this.grip.scale)
        
        // attach proxy to controller
        this.grip.updateMatrixWorld(true)
        this.controller.attach(this.grip)
        console.log('grab start', this)
	}

    onCurrent()
    {
        // update word grip 
        this.grip.updateMatrixWorld(true)
        
        // copy grip transform to object3d
        this.transform.copy(this.object3d.parent.matrixWorld).invert()
        this.transform.multiply(this.grip.matrixWorld)
        this.transform.decompose(this.object3d.position, this.object3d.quaternion, this.object3d.scale)
        
        // update world object
        this.object3d.updateMatrix()
        console.log('grab current', this)
    }

    onEnd()
    {
        // remove grip from controller
        this.controller.remove(this.grip)
        console.log('grab end', this)
    }

    pause() 
    {
        if (this.paused) return
        console.log('grab paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('grab resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.grip = null
    }
} 
