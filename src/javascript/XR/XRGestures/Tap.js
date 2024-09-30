import XRGestures from './XRGestures'

export default class Tap 
{
    constructor()
    {
        this.gestures = new XRGestures()
        this.parameters = this.gestures.parameters
        this.detector = this.gestures.detector

        this.setGesture()
    }

    setGesture()
    {
        this.start    = false
        this.current  = false
        this.end      = false
        this.userData = {}

        this.numTaps = 0
        
        this.gestures.addEventListener( 'tap', (event) => this.onGesture( event ) )        
    }

    detectGesture() {  

        if ( ! this.start ) {

            if ( this.detector.numControllers === 1 ) this.startGesture()

        }

        if ( this.current ) {

            if ( ! ( this.detector.numControllers === 0 )) return
            if ( ! ( this.parameters[0].duration < Tap.MAX_END_DURATION )) return
            if ( ! ( this.parameters[0].distance < Tap.MAX_END_DISTANCE )) return  

            this.numTaps += 1     

            this.gestures.dispatchEvent( { type: 'tap', start: true, current: true, end: true, numTaps: this.numTaps } )  
            this.endGesture()

        }

        if ( this.end ) {

            this.resetGesture()

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

        if (this.detector.gesture == 'tap')
            this.detector.gesture = undefined
    }

    onGesture( event ) {

        console.log( `tap` )

    }

}


Tap.MAX_END_DURATION = 150 // ms
Tap.MAX_END_DISTANCE = 10 // mm
