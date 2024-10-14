import * as THREE from 'three'
import Experience from '../../Experience'

import Tap from './Tap'
import Polytap from './Polytap'
import Hold from './Hold'
import Swipe from './Swipe'
import Pan from './Pan'
import Pinch from './Pinch'
import Twist from './Twist'
import Explode from './Explode'
import Implode from './Implode'

// standalone variables
const _vector   = new THREE.Vector2()
const _position = new THREE.Vector3()
const _cursor   = new THREE.Vector2()
const _cursor0  = new THREE.Vector2()
const _cursor1  = new THREE.Vector2()

// standalone functions
function delay( duration ) 
{  
    return new Promise( resolve => setTimeout( resolve, duration ) ) 
}
function formatVector( vector, digits ) 
{
    let sign = vector.toArray().map( (component) => ( component > 0 ) ? '+' : '-' )
    if ( vector instanceof THREE.Vector2 ) return `(${sign[0] + Math.abs(vector.x).toFixed(digits)}, ${sign[1] + Math.abs(vector.y).toFixed(digits)})`
    if ( vector instanceof THREE.Vector3 ) return `(${sign[0] + Math.abs(vector.x).toFixed(digits)}, ${sign[1] + Math.abs(vector.y).toFixed(digits)}, ${sign[2] + Math.abs(vector.z).toFixed(digits)})`
}

let instance = null

class XRGestures extends THREE.EventDispatcher 
{
    constructor() {

        super()     

        // Singleton
        if(instance)
            return instance
        instance = this
            
        this.experience = new Experience()
        this.renderer = this.experience.renderer.instance
        this.camera = this.renderer.xr.getCamera()
        
        this.numControllers = 0
        this.current = undefined
        this.delayed = false

        this.setRaycasters()
        this.setParameters()
        this.setControllers()
        this.setInventory()
    }

    // setup 

    setRaycasters() {

        this.raycasters = 
        {
            view: new THREE.Raycaster(),
            hand: [ 0, 1 ].map( () => new THREE.Raycaster() ),
        }
    }

    setParameters() {

        this.parameters = [ 0, 1 ].map( () => ({
            connected    : false,
            clock        : new THREE.Clock(),
            duration     : 0,
            cursor      : new THREE.Vector2(),
            cursor0     : new THREE.Vector2(),
            cursorOffset: new THREE.Vector2(),
            cursorBuffer: new Array( XRGestures.BUFFER_LENGTH ).fill().map( () => new THREE.Vector2() ),
            cursorSmooth: new Array( XRGestures.BUFFER_LENGTH ).fill().map( () => new THREE.Vector2() ),
            distance     : 0,
            angle        : 0,
            angleBuffer  : new Array( XRGestures.BUFFER_LENGTH ).fill( 0 ),
            radialSpeed  : 0,
            angularSpeed : 0,
            pathDistance : 0,
            turnAngle    : 0,
            pathSpeed    : 0,
            turnSpeed    : 0,
            turnDeviation: 0,
        }) )

        this.parametersDual = {
            connected:      false,
            clock         : new THREE.Clock(),
            duration      : 0,
            median        : new THREE.Vector2(),
            median0       : new THREE.Vector2(),
            medianOffset  : new THREE.Vector2(),
            vector        : new THREE.Vector2(),
            vector0       : new THREE.Vector2(),
            vectorBuffer  : new Array( XRGestures.BUFFER_LENGTH ).fill().map( () => new THREE.Vector2() ),
            distance      : 0,
            distance0     : 0,
            distanceOffset: 0,
            angle         : 0,
            angle0        : 0,
            angleOffset   : 0,
            turnAngle     : 0,
            angleBuffer   : new Array( XRGestures.BUFFER_LENGTH ).fill( 0 ),
            radialSpeed   : 0,
            angularSpeed  : 0,
        }

    }

    setControllers() {
        
        this.controller = [0, 1].map( (i) => this.renderer.xr.getController(i) )   
        this.controller.forEach( (controller, i) => 
        {
            controller.userData.index = i                     
            controller.userData.parameters = this.parameters[i]
            controller.userData.parametersDual = this.parametersDual

            controller.connectedListener = async (event) => await this.onConnected( event )
            controller.disconnectedListener = async (event) => await this.onDisconnected( event )
            controller.addEventListener( 'connected', controller.connectedListener)
            controller.addEventListener( 'disconnected', controller.disconnectedListener)            
        })     
    }

    setInventory() {

        this.inventory =  {
            tap    : new Tap(),
            polytap: new Polytap(),
            hold   : new Hold(),
            swipe  : new Swipe(),
            pan    : new Pan(),
            pinch  : new Pinch(),
            twist  : new Twist(),
            explode: new Explode(),
            implode: new Implode(),
        }
    }

    //  controllers
    
    async onConnected( event ) {
        
        const controller = event.target
        const index = controller.userData.index
        await delay( XRGestures.DELAY_CONTROLLER ) // need this to avoid some transient phenomenon, without it 

        this.numControllers += 1                            
        this.startParameters( index )

        if ( this.numControllers === 2 ) 
            this.startDualParameters()

    }

    async onDisconnected( event ) {

        const controller = event.target
        const index = controller.userData.index
        await delay( XRGestures.DELAY_CONTROLLER )

        this.numControllers -= 1 
        this.stopParameters( index )

        if ( this.numControllers < 2 ) 
            this.stopDualParameters()
    
    }     

    // update loop

    update() {  
     
        if ( ! this.renderer.xr.isPresenting ) console.error('Gestures must be in xr mode')

        this.camera.updateMatrix()    
        this.updateViewRaycaster()

        if ( this.parameters[0].connected ) {
            this.controller[0].updateMatrix()
            this.updateParameters(0)
            this.updateHandRaycaster(0)
        }

        if ( this.parameters[1].connected ) {
            this.controller[1].updateMatrix()
            this.updateParameters(1)
            this.updateHandRaycaster(1)
        }

        if ( this.parametersDual.connected ) {
            this.updateDualParameters()  
        }
        
        if ( ! this.delayed ) { 
            this.detect()
        } 

    }    

    destroy()
    {
        this.controller.forEach((controller) => 
        {
            if (controller.connectedListener) {
                controller.removeEventListener('connected', controller.connectedListener)
                controller.connectedListener = null
            }
            if (controller.disconnectedListener) {
                controller.removeEventListener('disconnected', controller.disconnectedListener)
                controller.disconnectedListener = null
            }
        })

         // Clean up individual raycasters
        if (this.raycasters) 
        {
            if (this.raycasters.view) 
                this.raycasters.view = null 
            
            if (this.raycasters.hand) 
                this.raycasters.hand.forEach((_, i) => { this.raycasters.hand[i] = null })
        }

        this.raycasters = null

        // Clean up parameters
        if (this.parameters)
            this.parameters.forEach((_, i) => this.destroyParameters(i))

        if (this.parametersDual)
            this.destroyDualParameters()
    
        // Clean up inventory items (gesture detectors)
        if (this.inventory) 
        {
            Object.keys(this.inventory).forEach((gesture) => 
            {
                if (this.inventory[gesture].destroy)
                    this.inventory[gesture].destroy() // Call a destroy method if available
                
                this.inventory[gesture] = null
            })

            this.inventory = null
        }
    
        // Nullify references
        this.experience = null
        this.renderer = null
        this.camera = null
        this.controller = null    

        console.log("XRGestures destroyed")
    }

    detect() {

        // order matters
        this.inventory.tap.detectGesture()                                   
        this.inventory.polytap.detectGesture()
        this.inventory.swipe.detectGesture()
        this.inventory.hold.detectGesture()
        this.inventory.pan.detectGesture()
        this.inventory.pinch.detectGesture()
        this.inventory.twist.detectGesture()
        this.inventory.explode.detectGesture()
        this.inventory.implode.detectGesture()

    }

    // parameters

    resetParameters( i ) {

        this.parameters[i].connected = false
        this.parameters[i].clock.stop()
        this.parameters[i].duration = 0
        this.parameters[i].cursor.set( 0, 0 )        
        this.parameters[i].cursor0.set( 0, 0 )
        this.parameters[i].cursorOffset.set( 0, 0 ) 
        this.parameters[i].cursorBuffer.forEach( (cursor) => cursor.set( 0, 0 ) )
        this.parameters[i].cursorSmooth.forEach( (cursor) => cursor.set( 0, 0 ) )
        this.parameters[i].distance = 0
        this.parameters[i].angle = 0
        this.parameters[i].angleBuffer.fill( 0 )
        this.parameters[i].radialSpeed = 0
        this.parameters[i].angularSpeed = 0
        this.parameters[i].pathDistance = 0 
        this.parameters[i].turnAngle = 0
        this.parameters[i].pathSpeed = 0
        this.parameters[i].turnSpeed = 0
        this.parameters[i].turnDeviation = 0

    }

    destroyParameters(i) {

        if (this.parameters[i].clock) {
            this.parameters[i].clock.stop()
            this.parameters[i].clock = null
        }
    
        this.parameters[i].cursor = null
        this.parameters[i].cursor0 = null
        this.parameters[i].cursorOffset = null
        this.parameters[i].cursorBuffer = null
        this.parameters[i].cursorSmooth = null
        this.parameters[i].connected = null
        this.parameters[i].duration = null
        this.parameters[i].distance = null
        this.parameters[i].angle = null
        this.parameters[i].angleBuffer = null
        this.parameters[i].radialSpeed = null
        this.parameters[i].angularSpeed = null
        this.parameters[i].pathDistance = null
        this.parameters[i].turnAngle = null
        this.parameters[i].pathSpeed = null
        this.parameters[i].turnSpeed = null
        this.parameters[i].turnDeviation = null
        this.parameters[i] = null
    }

    startParameters( i ) {

        this.resetParameters(i)
        this.parameters[i].connected = true
        this.parameters[i].clock.start()

        this.updateCursor(i)
        this.parameters[i].cursor0.copy( this.parameters[i].cursor )
        this.parameters[i].cursorBuffer.forEach( (cursor) => cursor.copy( this.parameters[i].cursor0 ) )
        this.parameters[i].cursorSmooth.forEach( (cursor) => cursor.copy( this.parameters[i].cursor0 ) )

    }

    stopParameters( i ) {

        this.parameters[i].connected = false
        this.parameters[i].clock.stop()

    }

    updateParameters( i ) {     
        
        this.updateDuration(i)
        this.updateCursor(i)
        this.updateCursorOffset(i)
        this.updateCursorBuffer(i)
        this.updateCursorSmooth(i)
        this.updateAngle(i) 
        this.updateAngleBuffer(i)
        this.updateTurnAngle(i)
        this.updateDistance(i)
        this.updateCoverDistance(i)
        this.updateRadialSpeed(i) 
        this.updateAngularSpeed(i)  
        this.updatePathSpeed(i) 
        this.updateTurnSpeed(i)  
        this.updateTurnDeviation(i)  

        // this.printParameters( i, 3 )

    } 

    printParameters( i, digits ) {

        console.log(`parameters${i}: \n\n\tduration = ${this.parameters[i].duration.toFixed(digits)} ms` )
        console.log(`parameters${i}: \n\n\tcursor = ${formatVector( this.parameters[i].cursor, digits )} mm` )
        console.log(`parameters${i}: \n\n\tcursor0 = ${formatVector( this.parameters[i].cursor0, digits )} mm` )
        console.log(`parameters${i}: \n\n\tcursorOffset = ${formatVector( this.parameters[i].cursorOffset, digits )} mm` )
        console.log(`parameters${i}: \n\n\tcursorBuffer[ 0 ] = ${formatVector( this.parameters[i].cursorBuffer[0], digits )} mm \n\n\tcursorBuffer[end] = ${formatVector( this.parameters[i].cursorBuffer[XRGestures.BUFFER_LENGTH - 1], digits )} mm`)
        console.log(`parameters${i}: \n\n\tcursorSmooth[ 0 ] = ${formatVector( this.parameters[i].cursorSmooth[0], digits )} mm \n\n\tcursorBuffer[end] = ${formatVector( this.parameters[i].cursorSmooth[XRGestures.BUFFER_LENGTH - 1], digits )} mm`)
        console.log(`parameters${i}: \n\n\tdistance = ${this.parameters[i].distance.toFixed(digits)} mm`)
        console.log(`parameters${i}: \n\n\tpathDistance = ${this.parameters[i].pathDistance.toFixed(digits)} mm`)
        console.log(`parameters${i}: \n\n\tangle = ${this.parameters[i].angle.toFixed(digits)} °`)
        console.log(`parameters${i}: \n\n\tturnAngle = ${this.parameters[i].turnAngle.toFixed(digits)} °`)
        console.log(`parameters${i}: \n\n\tangleBuffer[ 0 ] = ${this.parameters[i].angleBuffer[0].toFixed(digits)} ° \n\n\tangleBuffer[end] = ${this.parameters[i].angleBuffer[XRGestures.BUFFER_LENGTH - 1].toFixed(digits)} °`)
        console.log(`parameters${i}: \n\n\tradialSpeed = ${this.parameters[i].radialSpeed.toFixed(digits)} m/s`)
        console.log(`parameters${i}: \n\n\tangularSpeed = ${this.parameters[i].angularSpeed.toFixed(digits)} °/ms`)
        console.log(`parameters${i}: \n\n\tpathSpeed = ${this.parameters[i].pathSpeed.toFixed(digits)} m/s`)
        console.log(`parameters${i}: \n\n\tturnSpeed = ${this.parameters[i].turnSpeed.toFixed(digits)} °/ms`)
        console.log(`parameters${i}: \n\n\tturnDeviation = ${this.parameters[i].turnDeviation.toFixed(digits)} °/mm`)

    }

    updateDuration( i ) {

        this.parameters[i].duration = this.parameters[i].clock.getElapsedTime() * 1000 // ms

    }

    updateCursor( i ) {    
    
        _position.copy( this.controller[i].position ) // m
        _position.applyMatrix4( this.camera.matrixWorldInverse ) // m
        this.parameters[i].cursor.set( _position.x * 1000, _position.y * 1000 ) // mm

    }

    updateCursorBuffer( i ) {    
    
        this.parameters[i].cursorBuffer.unshift( this.parameters[i].cursorBuffer.pop() )  // mm
        this.parameters[i].cursorBuffer[0].copy( this.parameters[i].cursor ) // mm

    }

    updateCursorSmooth( i ) {
    
        // compute average cursor 
        _cursor.set( 0, 0 )
        for ( let n = 0; n < XRGestures.WINDOW_SMOOTH; ++n ) {
            _cursor.add( this.parameters[i].cursorBuffer[n] ) 
        }
        _cursor.divideScalar( XRGestures.WINDOW_SMOOTH ) // mm

        // save in buffer
        this.parameters[i].cursorSmooth.unshift( this.parameters[i].cursorSmooth.pop() )  // mm
        this.parameters[i].cursorSmooth[0].copy( _cursor ) // mm

    }

    updateCursorOffset( i ) {

        this.parameters[i].cursorOffset.subVectors(
            this.parameters[i].cursor,
            this.parameters[i].cursor0,        
        ) 
       
    }
    
    updateDistance( i ) {

        this.parameters[i].distance = this.parameters[i].cursorOffset.length() // mm

    }

    updateCoverDistance( i ) {
        
        _cursor0.copy( this.parameters[i].cursorSmooth[0] ) // mm
        _cursor1.copy( this.parameters[i].cursorSmooth[1] ) // mm
        let step = _vector.subVectors( _cursor0, _cursor1 ).length()  
        this.parameters[i].pathDistance += step // mm

    }

    updateAngle( i ) {   

        let angle = THREE.MathUtils.radToDeg( this.parameters[i].cursorOffset.angle() )  // °       
        if ( this.parameters[i].distance < 0.1 ) angle = 0 // °  
        
        let step = angle - this.parameters[i].angle // °         
        if ( Math.abs(step) > 180 )  step -= 360 * Math.sign( step ) // °  

        this.parameters[i].angle += step  // °  

    }

    updateAngleBuffer( i ) {

        this.parameters[i].angleBuffer.unshift( this.parameters[i].angleBuffer.pop() ) 
        this.parameters[i].angleBuffer[0] = this.parameters[i].angle

    }

    updateTurnAngle( i ) {       

        let step = Math.abs( this.parameters[i].angleBuffer[0] - this.parameters[i].angleBuffer[1] ) // °                           
        this.parameters[i].turnAngle += step  // °  

    } 

    updateRadialSpeed( i ) {  

        this.parameters[i].radialSpeed = this.parameters[i].distance / this.parameters[i].duration // m/s

    }

    updateAngularSpeed( i ) {

        this.parameters[i].angularSpeed = this.parameters[i].angle / this.parameters[i].duration // °/ms

    }

    updatePathSpeed( i ) {  

        this.parameters[i].pathSpeed = this.parameters[i].pathDistance / this.parameters[i].duration // m/s

    }

    updateTurnSpeed( i ) {

        this.parameters[i].turnSpeed = this.parameters[i].turnAngle / this.parameters[i].duration // °/ms

    }

    updateTurnDeviation( i ) {
    
        this.parameters[i].turnDeviation = this.parameters[i].turnAngle / this.parameters[i].pathDistance // °/mm

        if ( this.parameters[i].pathDistance < 0.01 ) this.parameters[i].turnDeviation = 0
            

    }   

    // dual parameters

    resetDualParameters() {

        this.parametersDual.connected = false
        this.parametersDual.clock.stop()
        this.parametersDual.duration = 0
        this.parametersDual.median.set( 0, 0 )    
        this.parametersDual.median0.set( 0, 0 )   
        this.parametersDual.medianOffset.set( 0, 0 )     
        this.parametersDual.vector.set( 0, 0 )
        this.parametersDual.vector0.set( 0, 0 )
        this.parametersDual.vectorBuffer.forEach((vector) => vector.set( 0, 0 )),
        this.parametersDual.distance = 0
        this.parametersDual.distance0 = 0
        this.parametersDual.distanceOffset = 0
        this.parametersDual.angle = 0
        this.parametersDual.angle0 = 0
        this.parametersDual.angleOffset = 0
        this.parametersDual.turnAngle = 0
        this.parametersDual.angleBuffer.fill( 0 )
        this.parametersDual.radialSpeed = 0
        this.parametersDual.angularSpeed = 0
    }

    destroyDualParameters() {

        if (this.parametersDual.clock) {
            this.parametersDual.clock.stop()
            this.parametersDual.clock = null
        }
    
        this.parametersDual.median = null
        this.parametersDual.median0 = null
        this.parametersDual.medianOffset = null
        this.parametersDual.vector = null
        this.parametersDual.vector0 = null
        this.parametersDual.vectorBuffer = null
        this.parametersDual.connected = null
        this.parametersDual.duration = null
        this.parametersDual.distance = null
        this.parametersDual.distance0 = null
        this.parametersDual.distanceOffset = null
        this.parametersDual.angle = null
        this.parametersDual.angle0 = null
        this.parametersDual.angleOffset = null
        this.parametersDual.turnAngle = null
        this.parametersDual.angleBuffer = null
        this.parametersDual.radialSpeed = null
        this.parametersDual.angularSpeed = null
        this.parametersDual = null
    }
    

    startDualParameters() {
        
        this.resetDualParameters()
        this.parametersDual.connected = true    
        this.parametersDual.clock.start()

        this.updateDualVector()
        this.parametersDual.vector0.copy( this.parametersDual.vector )
        this.parametersDual.vectorBuffer.forEach((vector) => vector.copy( this.parametersDual.vector0 ))

        this.updateDualDistance()
        this.parametersDual.distance0 = this.parametersDual.distance
        
        this.updateDualAngle()
        this.parametersDual.angle0 = this.parametersDual.angle
        this.parametersDual.angleBuffer.fill( this.parametersDual.angle0 )
        
        this.updateDualMedian()
        this.parametersDual.median0.copy( this.parametersDual.median )

    }

    stopDualParameters() {

        this.parametersDual.connected = false        
        this.parametersDual.clock.stop()

    }

    updateDualParameters() {

        this.updateDualDuration()
        this.updateDualMedian()
        this.updateDualMedianOffset()
        this.updateDualVector()
        this.updateDualVectorBuffer()
        this.updateDualDistance()
        this.updateDualDistanceOffset()
        this.updateDualAngle() 
        this.updateDualAngleOffset()
        this.updateDualAngleBuffer()
        this.updateDualTurnAngle()
        this.updateDualRadialSpeed()   
        this.updateDualAngularSpeed()  

        // this.printDualParameters( 3 )
    } 

    printDualParameters( digits ) {

        console.log(`parametersDual: \n\n\tduration = ${this.parametersDual.duration.toFixed(digits)} ms` )
        console.log(`parametersDual: \n\n\tmedian = ${formatVector( this.parametersDual.median, digits )} mm` )
        console.log(`parametersDual: \n\n\tmedian0 = ${formatVector( this.parametersDual.median0, digits )} mm` )
        console.log(`parametersDual: \n\n\tvector = ${formatVector( this.parametersDual.vector, digits )} mm` )
        console.log(`parametersDual: \n\n\tvector0 = ${formatVector( this.parametersDual.vector0, digits )} mm` )
        console.log(`parametersDual: \n\n\tvectorBuffer[ 0 ] = ${formatVector( this.parametersDual.vectorBuffer[0], digits )} mm \n\n\tcursorBuffer[end] = ${formatVector( this.parametersDual.vectorBuffer[XRGestures.BUFFER_LENGTH - 1], digits )} mm`)
        console.log(`parametersDual: \n\n\tdistance = ${this.parametersDual.distance.toFixed(digits)} mm`)
        console.log(`parametersDual: \n\n\tdistance0 = ${this.parametersDual.distance0.toFixed(digits)} mm`)
        console.log(`parametersDual: \n\n\tdistanceOffset = ${this.parametersDual.distanceOffset.toFixed(digits)} mm`)
        console.log(`parametersDual: \n\n\tangle = ${this.parametersDual.angle.toFixed(digits)} °`)
        console.log(`parametersDual: \n\n\tangle0 = ${this.parametersDual.angle0.toFixed(digits)} °`)
        console.log(`parametersDual: \n\n\tangleOffset = ${this.parametersDual.angleOffset.toFixed(digits)} °`)
        console.log(`parametersDual: \n\n\tturnAngle = ${this.parametersDual.turnAngle.toFixed(digits)} °`)
        console.log(`parametersDual: \n\n\tangleBuffer[ 0 ] = ${this.parametersDual.angleBuffer[0].toFixed(digits)} ° \n\n\tangleBuffer[end] = ${this.parametersDual.angleBuffer[XRGestures.BUFFER_LENGTH - 1].toFixed(digits)} °`)
        console.log(`parametersDual: \n\n\tradialSpeed = ${this.parametersDual.radialSpeed.toFixed(digits)} m/s`)
        console.log(`parametersDual: \n\n\tangularSpeed = ${this.parametersDual.angularSpeed.toFixed(digits)} °/ms`)    

    }

    updateDualDuration() {

        this.parametersDual.duration = this.parametersDual.clock.getElapsedTime() * 1000 // ms

    }

    updateDualVector() {
      
        _cursor0.copy( this.parameters[0].cursor ) // mm
        _cursor1.copy( this.parameters[1].cursor ) // mm        
        this.parametersDual.vector.subVectors( _cursor1, _cursor0 ) // mm   

    }

    updateDualVectorBuffer() {
        
        this.parametersDual.vectorBuffer.unshift( this.parametersDual.vectorBuffer.pop() ) 
        this.parametersDual.vectorBuffer[0].copy( this.parametersDual.vector )   

    }

    updateDualDistance() {

        this.parametersDual.distance = this.parametersDual.vector.length() // mm

    }

    updateDualDistanceOffset() {
        
        this.parametersDual.distanceOffset = this.parametersDual.distance -  this.parametersDual.distance0

    }

    updateDualAngle() {

        let angle = THREE.MathUtils.radToDeg( this.parametersDual.vector.angle() )  // °       
        let step = angle - this.parametersDual.angle // ° 
        if ( Math.abs( step ) > 180 )  step -= 360 * Math.sign( step ) // °

        this.parametersDual.angle += step  // °     

    }

    updateDualAngleOffset() {
        
        this.parametersDual.angleOffset = this.parametersDual.angle -  this.parametersDual.angle0

    }

    updateDualAngleBuffer() {

        this.parametersDual.angleBuffer.unshift( this.parametersDual.angleBuffer.pop() ) 
        this.parametersDual.angleBuffer[0] = this.parametersDual.angle

    }

    updateDualTurnAngle() {     

        let step = Math.abs( this.parametersDual.angleBuffer[0] - this.parametersDual.angleBuffer[1] ) // °                           
        this.parametersDual.turnAngle += step // °  

    }

    updateDualMedian() {

        _cursor0.copy( this.parameters[0].cursor ) // mm
        _cursor1.copy( this.parameters[1].cursor ) // mm
        this.parametersDual.median.addVectors( _cursor0, _cursor1 ).subScalar( 2 )

    }

    updateDualMedianOffset() {

        this.parametersDual.medianOffset.subVectors( 
            this.parametersDual.median, 
            this.parametersDual.median0,
        )

    }

    updateDualRadialSpeed() {

        this.parametersDual.radialSpeed = this.parametersDual.distanceOffset / this.parametersDual.duration // m/s

    }

    updateDualAngularSpeed() {

        this.parametersDual.angularSpeed = this.parametersDual.angleOffset / this.parametersDual.duration //  °/ms

    }

    // update raycasters

    updateViewRaycaster() {

        this.camera.getWorldPosition( this.raycasters.view.ray.origin )
        this.camera.getWorldDirection( this.raycasters.view.ray.direction )
        // console.log(`viewRay.direction = ${formatVector( this.raycasters.viewRay.direction, 2 )} mm`)

    }

    updateHandRaycaster( i ) {
        
        this.controller[i].getWorldPosition( this.raycasters.hand[i].ray.origin )
        this.controller[i].getWorldDirection( this.raycasters.hand[i].ray.direction ).negate()
        // console.log(`handRay[${i}].direction = ${formatVector( this.raycasters.handRay[i].direction, 2 )} mm`)

    }

    // helper functions

    resetGesturesExcept( exception ) {

        for (const gesture in this.inventory) {
            if( gesture !== exception ) this.inventory[gesture].resetGesture()
        }    

    }

    resetGestures() {

        for (const gesture in this.inventory) {
            this.inventory[gesture].resetGesture()
        }                
    }

    delayGestures( delay ) {

        this.delayed = true
        setTimeout( () => this.delayed = false, delay )

    }

    // utils

    reduceAngle ( theta ) {

        return ((theta + 180) % 360 + 360) % 360 - 180

    }

    branchFromAngle ( theta ) {

        return Math.floor((theta + 180) / 360)
        
    }

    sectorFromAngle ( theta, divisor ) {

        const slice = 360 / divisor 
        return THREE.MathUtils.euclideanModulo( Math.round( theta / slice ), divisor) // degree

    }

}

XRGestures.DELAY_CONTROLLER = 20 // ms    
XRGestures.DELAY_DETECTOR = 100 // ms
XRGestures.BUFFER_LENGTH = 2 
XRGestures.WINDOW_SMOOTH = 1

export default XRGestures