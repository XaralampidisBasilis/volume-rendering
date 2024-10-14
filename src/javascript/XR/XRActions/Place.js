

import Experience from '../../Experience'

export default class Place
{
    constructor(object3D, gestureEvent)
    {
        this.object3D = object3D
        this.gestureEvent = gestureEvent

        this.experience = new Experience()
        this.hitTest = this.experience.xr.hitTest
        this.gestures = this.experience.xr.gestures
        this.addListener()       
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener(this.gestureEvent, this.listener)
    }

    onGesture(event)
    {
        if (event.numTaps == 2)
        {
            if (event.start) this.onStart()
            if (event.current) this.onCurrent()
            if (event.end) this.onEnd()
        }
    }

    onStart()
    {
 
	}

    onCurrent()
    {
       
    }

    onEnd()
    {
        if (this.object3D.visible === false) 
        {
            this.object3D.position.setFromMatrixPosition(this.hitTest.reticle.mesh.matrix)
            this.object3D.visible = true
        }
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gestureEvent, this.listener)
        this.gestureEvent = null
        this.object3D = null
        this.experience = null
        this.hitTest = null
        this.gestures = null
    }
} 
