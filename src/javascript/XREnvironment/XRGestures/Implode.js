import XRGestures from './XRGestures'

export default class Implode 
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
        this.gestures.addEventListener( 'implode', this.listener )     
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined )) return
            if ( ! ( this.gestures.numControllers === 2 )) return
            if ( ! ( this.parametersDual.distanceOffset  < Implode.MAX_START_DISTANCE_OFFSET )) return
            if ( ! ( Math.abs( this.parametersDual.radialSpeed ) > Implode.MIN_START_RADIAL_SPEED )) return
            
            this.startGesture()

        }

        if ( this.current ) {

            if ( this.gestures.numControllers < 2 ) {

                this.gestures.current = 'implode'
                this.gestures.resetGesturesExcept('implode')
                this.endGesture()

            }        
            
        }

        if ( this.end ) {  

            this.gestures.dispatchEvent( { type: 'implode', start: true, current: true, end: true, userData: this.userData, } )
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

        if (this.gestures.current == 'implode')
            this.gestures.current = undefined
    }

    onGesture( event ) 
    {
        console.log(`implode`)       
    }

    destroy()
    {
        this.gestures.removeEventListener('implode', this.listener)
        this.listener = null
        this.gestures = null
        this.parametersDual = null
        this.start    = null
        this.current  = null
        this.end      = null
        this.userData = null

        console.log("Implode destroyed")
    }

}

// gesture constants

Implode.MAX_START_DISTANCE_OFFSET = 11 // mm 
Implode.MIN_START_RADIAL_SPEED = 0.12 // mm 

