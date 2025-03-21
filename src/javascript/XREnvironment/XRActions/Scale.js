
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class Scale
{
    constructor(object3d, gesture = 'pinch')
    {
        this.xrManager = new XREnvironment()
        this.gestures = this.xrManager.gestures
        this.parameters = this.gestures.parametersDual

        this.object3d = object3d
        this.gesture = gesture
        this.paused = false

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.ratio = 1
        this.scale = new THREE.Vector3()
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
        this.ratio = 1
        this.scale.copy(this.object3d.scale)
        console.log('scale current', this)
	}

    onCurrent()
    {
        this.ratio = (this.parameters.distance / this.parameters.distance0) ** Scale.DISTANCE_RATIO_EXPONENT

        this.object3d.scale.copy(this.scale).multiplyScalar(this.ratio)
        console.log('scale current', this)
    }

    onEnd()
    {
        console.log('scale current', this)
    }

    pause() 
    {
        if (this.paused) return
        console.log('scale paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('scale resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.object3d = null
        this.ratio = null
        this.scale = null
    }
} 

// action constants
Scale.DISTANCE_RATIO_EXPONENT = 1.5
