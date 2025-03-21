
import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class GuidedTranslation
{
    constructor(object3d, gesture = 'hold', origin, direction)
    {
        this.xrManager = new XREnvironment()
        this.gestures = this.xrManager.gestures
        this.scene = this.xrManager.scene
        this.viewRay = this.gestures.raycasters.view.ray
        this.handRay = this.gestures.raycasters.hand[0].ray

        this.object3d = object3d
        this.origin = origin  
        this.direction = direction
        this.gesture = gesture
        this.paused = false

        this.initialize()
        this.addListener()       
    }

    initialize()
    {
        this.parent = this.object3d.parent

        this.position = new THREE.Vector3()
        this.translation = new THREE.Vector3()
        this.intersection = new THREE.Vector3()
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
        this.scene.attach(this.object3d) 
        
        // Get world position
        this.position.copy(this.object3d.position)
        
        // Set normal from camera direction 
        this.plane.normal.copy(this.viewRay.direction)
        this.plane.normal.projectOnPlane(this.direction).normalize()
        
        // Set guide plane
        this.plane.setFromNormalAndCoplanarPoint(this.plane.normal, this.origin)
        console.log('guided translation start', this)
    }

    onCurrent()
    {
        
        // Update normal from camera direction 
        this.plane.normal.copy(this.viewRay.direction)
        this.plane.normal.projectOnPlane(this.direction).normalize()
        
        // Update plane
        this.plane.normalize()
        
        // Intersect ray and plane
        this.handRay.intersectPlane(this.plane, this.intersection)
        
        // If intersected translate object
        if (this.intersection) 
        {
            this.translation.subVectors(this.intersection, this.origin).projectOnVector(this.direction)
            this.object3d.position.copy(this.position).add(this.translation)
        }

        console.log('guided translation current', this)
    }

    onEnd()
    {
        // Reattach object to parent
        this.parent.attach(this.object3d)
        console.log('guided translation end', this)
    }

    pause() 
    {
        if (this.paused) return
        console.log('guided translation paused')
        this.paused = true
    }

    resume() 
    {
        if (!this.paused) return
        console.log('guided translation resumed')
        this.paused = false
    }

    destroy() 
    {
        if (this.listener) 
        {
            this.gestures.removeEventListener(this.gesture, this.listener)
            this.listener = null
        }
    
        this.object3d = null
        this.parent = null
        this.position = null
        this.plane = null
        this.intersection = null
        this.translation = null
        this.origin = null
        this.direction = null
    }
} 