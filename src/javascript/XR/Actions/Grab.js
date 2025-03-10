

import Gestures from '../Gestures/Gestures'

export default class Grab
{
    constructor(object3d, gesture = 'hold')
    {
        this.gestures = new Gestures()
        this.controller = this.gestures.controller[0]
        this.object3d = object3d
        this.gesture = gesture

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
		this.proxy = new THREE.Object3D()
        this.transform = new THREE.Matrix4()
    }

    addListener()
    {
        this.listener = (event) => this.onGesture(event)
        this.gestures.addEventListener(this.gesture, this.listener)
    }

    onGesture(event)
    {
        if (event.start) this.onStart()
        if (event.current) this.onCurrent()
        if (event.end) this.onEnd()
    }

    onStart()
    {
        this.object3d.matrixWorld.decompose(this.proxy.position, this.proxy.quaternion, this.proxy.scale)
        this.proxy.updateMatrixWorld(true)
        this.controller.attach(this.proxy)
	}

    onCurrent()
    {
        this.proxy.updateMatrixWorld(true)

        this.transform.copy(this.object3d.parent.matrixWorld).invert()
        this.transform.multiply(this.proxy.matrixWorld)
        this.transform.decompose(this.object3d.position, this.object3d.quaternion, this.object3d.scale)

        this.object3d.updateMatrix()
    }

    onEnd()
    {
        this.controller.remove(this.proxy)
    }

    destroy() 
    {
        this.gestures.removeEventListener(this.gesture, this.listener)
        this.point = null
    }
} 
