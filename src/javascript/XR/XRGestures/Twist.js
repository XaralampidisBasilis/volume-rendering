import XRGestures from './XRGestures'

export default class Twist 
{
    constructor()
    {
        this.gestures = new XRGestures()
        this.parametersDual = this.gestures.parametersDual
        this.detector = this.gestures.detector

        this.setGesture()          
    }

    setGesture()
    {
        this.start    = false
        this.current  = false
        this.end      = false
        this.userData = {}

        this.gestures.addEventListener( 'twist', (event) => this.onGesture( event ) )     
    }

    detectGesture() {
        
        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.detector.numControllers === 2 ) ) return
            if ( ! ( this.parametersDual.distance > Twist.MIN_START_DISTANCE ) ) return
            if ( ! ( Math.abs( this.parametersDual.distanceOffset ) < Twist.MAX_START_DISTANCE_OFFSET ) ) return
            if ( ! ( Math.abs( this.parametersDual.angleOffset ) > Twist.MIN_START_ANGLE_OFFSET ) ) return

            this.detector.gesture = 'twist'         
               
            this.gestures.dispatchEvent( { type: 'twist', start: true, userData: this.userData, } )                
            this.gestures.resetGesturesExcept('twist')
            this.startGesture()

        } 

        if ( this.current ) {           

            this.gestures.dispatchEvent( { type: 'twist', current: true, userData: this.userData, } )
        
            if ( this.detector.numControllers < 2 ) this.endGesture()        

        } 
        
        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'twist', end: true, userData: this.userData, } )
            this.gestures.delayDetector( XRGestures.DELAY_DETECTOR ) 
            this.gestures.resetGestures()

        }
    }

    startGesture()
    {
        this.start   = true
        this.current = true
    }

    endGesture()
    {
        this.current = false
        this.end     = true
    }

    resetGesture()
    {
        this.start   = false
        this.current = false
        this.end     = false

        if (this.detector.gesture == 'twist')
            this.detector.gesture = undefined
    }

    onGesture( event ) {
        
        if ( event.start )   console.log( `twist start` )
        if ( event.current ) console.log( `twist current` )
        if ( event.end )     console.log( `twist end` )

    }

}

// gesture constants

Twist.MIN_START_DISTANCE = 30 // mm
Twist.MAX_START_DISTANCE_OFFSET = 5  // mm
Twist.MIN_START_ANGLE_OFFSET = 10 // °
