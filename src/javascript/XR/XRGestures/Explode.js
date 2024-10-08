import XRGestures from './XRGestures'

export default class Explode 
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

        this.gestures.addEventListener( 'explode', (event) => this.onGesture( event ) )     
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.detector.numControllers === 2 )) return
            if ( ! ( this.parametersDual.distanceOffset > Explode.MIN_START_DISTANCE_OFFSET )) return
            if ( ! ( Math.abs( this.parametersDual.radialSpeed ) > Explode.MIN_START_RADIAL_SPEED)) return

            this.startGesture()

        }

        if ( this.current ) {

            if ( this.detector.numControllers < 2 ) {

                this.detector.gesture = 'explode'

                this.gestures.resetGesturesExcept( 'explode' )
                this.endGesture()

            }
           
        }

        if ( this.end ) {  

            this.gestures.dispatchEvent( { type: 'explode', start: true, current: true, end: true, userData: this.userData, } )
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

        if (this.detector.gesture == 'explode')
            this.detector.gesture = undefined
    }

    onGesture( event ) {
        
        console.log( `explode` )       

    }

}

// gesture constants

Explode.MIN_START_DISTANCE_OFFSET = 11 // mm 
Explode.MIN_START_RADIAL_SPEED = 0.12 // mm 

