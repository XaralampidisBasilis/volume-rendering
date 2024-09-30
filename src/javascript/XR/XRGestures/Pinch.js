import XRGestures from './XRGestures'

export default class Pinch 
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

        this.gestures.inventory.pinch = this 
        this.gestures.addEventListener( 'pinch', (event) => this.onGesture( event ) )     
    }

    detectPinch() {

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined ) ) return
            if ( ! ( this.detector.numConnected === 2 ) ) return
            if ( ! ( Math.abs( this.parametersDual.distanceOffset ) > Pinch.MIN_START_DISTANCE_OFFSET ) ) return
            if ( ! ( Math.abs( this.parametersDual.angleOffset ) < Pinch.MAX_START_ANGLE_OFFSET ) ) return
            if ( ! ( Math.abs( this.parametersDual.radialSpeed ) < Pinch.MAX_START_RADIAL_SPEED )) return   

            this.detector.gesture = 'pinch'           

            this.gestures.dispatchEvent( { type: 'pinch', start: true, userData: this.userData } )
            this.gestures.resetGesturesExcept('pinch')
            this.startGesture()
        } 

        if ( this.current ) {
           
            this.dispatchEvent( { type: 'pinch', current: true, userData: this.userData } )
        
            if ( this.detector.numConnected < 2 ) this.endGesture()

        } 
        
        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'pinch', end: true, userData: this.userData } )
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

        if (this.detector.gesture == 'pinch')
            this.detector.gesture = undefined
    }

    onGesture( event ) {
        
        if ( event.start )   console.log( `pinch start` )
        if ( event.current ) console.log( `pinch current` )
        if ( event.end )     console.log( `pinch end` )

    }

}

// gesture constants

Pinch.MIN_START_DISTANCE_OFFSET = 5 // mm
Pinch.MAX_START_ANGLE_OFFSET = 10 // °
Pinch.MAX_START_RADIAL_SPEED = 0.12 // m/s
