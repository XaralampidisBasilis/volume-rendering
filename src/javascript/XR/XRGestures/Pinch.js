import XRGestures from './XRGestures'

export default class Pinch 
{
    constructor()
    {
        this.gestures = new XRGestures()
        this.parametersDual = this.gestures.parametersDual
        this.setGesture()          
    }

    setGesture()
    {
        this.start    = false
        this.current  = false
        this.end      = false
        this.userData = {}
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'pinch', this.listener )   
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined ) ) return
            if ( ! ( this.gestures.numControllers === 2 ) ) return
            if ( ! ( Math.abs( this.parametersDual.distanceOffset ) > Pinch.MIN_START_DISTANCE_OFFSET ) ) return
            if ( ! ( Math.abs( this.parametersDual.angleOffset ) < Pinch.MAX_START_ANGLE_OFFSET ) ) return
            if ( ! ( Math.abs( this.parametersDual.radialSpeed ) < Pinch.MAX_START_RADIAL_SPEED )) return   

            this.gestures.current = 'pinch'           
            this.gestures.dispatchEvent( { type: 'pinch', start: true, userData: this.userData } )
            this.gestures.resetGesturesExcept('pinch')
            this.startGesture()
        } 

        if ( this.current ) {
           
            this.gestures.dispatchEvent( { type: 'pinch', current: true, userData: this.userData } )
        
            if ( this.gestures.numControllers < 2 ) this.endGesture()

        } 
        
        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'pinch', end: true, userData: this.userData } )
            this.gestures.delayGestures( XRGestures.DELAY_DETECTOR ) 
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

        if (this.gestures.current == 'pinch')
            this.gestures.current = undefined
    }

    onGesture( event ) {
        
        if ( event.start )   console.log( `pinch start` )
        if ( event.current ) console.log( `pinch current` )
        if ( event.end )     console.log( `pinch end` )

    }

    destroy()
    {
        this.gestures.removeEventListener('pinch', this.listener)
        this.listener = null
        this.gestures = null
        this.parametersDual = null
        this.start    = null
        this.current  = null
        this.end      = null
        this.userData = null

        console.log("Pinch destroyed")
    }

}

// current constants

Pinch.MIN_START_DISTANCE_OFFSET = 5 // mm
Pinch.MAX_START_ANGLE_OFFSET = 10 // °
Pinch.MAX_START_RADIAL_SPEED = 0.12 // m/s
