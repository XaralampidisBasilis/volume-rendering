
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class GuidedRotation
{
    constructor(object3D, gesture = 'pan', pivot, axis)
    {
    
        this.xrManager = new XREnvironment()
        this.gestures = this.xrManager.gestures
        this.scene = this.xrManager.scene
        this.handRay = this.gestures.raycasters.hand[0].ray

        this.object3D = object3D
        this.pivot = pivot 
        this.axis = axis
        this.gesture = gesture
        this.paused = false

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.parent = this.object3D.parent

        this.quaternion = new THREE.Quaternion()
        this.intersection = new THREE.Vector3()
        this.lever = new THREE.Vector3()
        this.coords = new THREE.Vector2()
        this.xAxis = new THREE.Vector3()
        this.yAxis = new THREE.Vector3()
        this.plane = new THREE.Plane()
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
        // Object becomes a world object
        this.scene.attach(this.object3D) 
        
        // Get world position and quaternion
        this.quaternion.copy(this.object3D.quaternion)
        
        // Set guide plane
        this.plane.setFromNormalAndCoplanarPoint(this.axis, this.pivot)
        
        // Intersect ray and plane
        this.handRay.intersectPlane(this.plane, this.intersection)
        
        // Compute lever vector
        this.lever.copy(this.intersection).sub(this.pivot)
        
        // Compute plane coordinate system
        this.xAxis.copy(this.lever).normalize()
        this.yAxis.copy(this.xAxis).applyAxisAngle(this.axis, Math.PI / 2).normalize()
        console.log('guided rotation start', this)
    }

    onCurrent()
    {
        // Intersect ray and plane
        this.handRay.intersectPlane(this.plane, this.intersection)
        
        // If intersected rotate object
        if (this.intersection) 
        {
            // Update lever 
            this.lever.copy(this.intersection).sub(this.pivot)
            
            // Update angle of rotation
            this.coords.set(this.lever.dot(this.xAxis), this.lever.dot(this.yAxis))
            this.angle = this.coords.length() > 0.01 ? this.coords.angle() : 0
            
            // Update object rotation
            this.object3D.quaternion.copy(this.quaternion)
            this.object3D.rotateOnWorldAxis(this.axis, this.angle)
        }
        console.log('guided rotation current', this)
    }

    onEnd()
    {
        // Reattach object to parent
        this.parent.attach(this.object3D)
        console.log('guided rotation end', this)
    }
    
    pause() 
    {
        if (this.paused) return
        console.log('guided rotation paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('guided rotation resumed')
        this.paused = false
    }

    destroy() 
    {
        if (this.listener) 
        {
            this.gestures.removeEventListener(this.gesture, this.listener)
            this.listener = null
        }
    
        this.object3D = null
        this.parent = null
        this.pivot = null
        this.axis = null
        
        this.quaternion = null
        this.intersection = null
        this.lever = null
        this.coords = null
        this.xAxis = null
        this.yAxis = null
        this.plane = null
    }
} 
