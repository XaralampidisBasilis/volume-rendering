

import XRGestures from '../XRGestures/XRGestures'

export default class Scale
{
    constructor(object3D, gestureEvent)
    {
        this.object3D = object3D
        this.gestureEvent = gestureEvent
        this.gestures = new XRGestures()
        this.addListener()       
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
        this.distanceRatio = 1
        this.scale0 = this.object3D.scale.clone()
	}

    onCurrent()
    {
        this.distanceRatio = this.gestures.parametersDual.distance / this.gestures.parametersDual.distance0
        this.distanceRatio = this.distanceRatio ** Scale.DISTANCE_RATIO_EXPONENT

        this.object3D.scale.copy(this.scale0)
        this.object3D.scale.multiplyScalar(this.distanceRatio)
    }

    onEnd()
    {
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gestureEvent, this.listener)
        this.gestureEvent = null
        this.object3D = null
        this.distanceRatio = null
        this.scale0 = null
    }
} 

// action constants
Scale.DISTANCE_RATIO_EXPONENT = 1.5
