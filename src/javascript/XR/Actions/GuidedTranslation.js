

    import Gestures from '../Gestures/Gestures'


    export default class GuidedTranslation
    {
        constructor(object3D, origin, direction, gesture = 'hold')
        {
        
            this.gestures = new Gestures()
            this.scene = this.gestures.scene
            this.viewRay = this.gestures.raycasters.view.ray
            this.handRay = this.gestures.raycasters.hand[0].ray

            this.object3D = object3D
            this.origin = origin  
            this.direction = direction
            this.gesture = gesture

            this.initialize()
            this.addListener()       
        }

        initialize()
        {
            this.parent = this.object3D.parent

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
            if (event.start) this.onStart()
            if (event.current) this.onCurrent()
            if (event.end) this.onEnd()
        }

        onStart()
        {        
            // Object becomes a world object
            this.scene.attach(this.object3D) 

            // Get world position
            this.position.copy(this.object3D.position)

            // Set normal from camera direction 
            this.plane.normal.copy(this.viewRay.direction)
            this.plane.normal.projectOnPlane(this.direction).normalize()

            // Set guide plane
            this.plane.setFromNormalAndCoplanarPoint(this.plane.normal, this.origin)
        }

        onCurrent()
        {
            // Update normal from camera direction 
            this.plane.normal.copy(this.viewRay.direction).projectOnPlane(this.direction)

            // Update plane
            this.plane.normalize()

            // Intersect ray and plane
            this.handRay.intersectPlane(this.plane, this.intersection)

            // If intersected translate object
            if (this.intersection) 
            {
                this.translation.subVectors(this.intersection, this.origin).projectOnVector(this.direction)
                this.object3D.position.copy(this.position).add(this.translation)
            }
        }

        onEnd()
        {
            // Reattach object to parent
            this.parent.attach(this.object3D)
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
            this.position = null
            this.plane = null
            this.intersection = null
            this.translation = null
            this.origin = null
            this.direction = null
        }
    } 