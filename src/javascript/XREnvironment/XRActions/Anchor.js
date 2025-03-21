

import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class Anchor
{
    constructor(object3d)
    {
        this.xrManager = new XREnvironment()
        this.experience = this.xrManager.experience
        this.gestures = this.xrManager.gestures
        this.hitTest = this.xrManager.hitTest
        this.gestures = this.xrManager.gestures

        this.object3d = object3d
        this.gesture = 'polytap'
        this.paused = false

        this.addListener()       
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener(this.gesture, this.listener)
    }

    onGesture(event)
    {
        if (this.paused) return
        
        if (event.numTaps == 2)
        {
            if (event.start) this.onStart()
            if (event.current) this.onCurrent()
            if (event.end) this.onEnd()
        }
    }

    onStart()
    {
        console.log('anchor start', this)
	}

    onCurrent()
    {
        console.log('anchor current', this)

    }

    onEnd()
    {
        this.object3d.position.setFromMatrixPosition(this.hitTest.reticle.mesh.matrix)
        console.log('anchor end', this)
    }

    pause() 
    {
        if (this.paused) return
        console.log('anchor paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('anchor resumed')
        this.paused = false
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.gesture = null
        this.object3d = null
        this.experience = null
        this.hitTest = null
        this.gestures = null
    }
} 
