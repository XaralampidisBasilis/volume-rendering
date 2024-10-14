import XRGestures from './XRGestures'

export default class Tap 
{
    constructor()
    {
        this.gestures = new XRGestures()
        this.parameters = this.gestures.parameters
        this.setGesture()
    }

    setGesture()
    {
        this.start    = false
        this.current  = false
        this.end      = false
        this.userData = {}
        this.numTaps = 0
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'tap', this.listener )         
    }

    detectGesture() {  

        if ( ! this.start ) {

            if ( this.gestures.numControllers === 1 ) this.startGesture()

        }

        if ( this.current ) {

            if ( ! ( this.gestures.numControllers === 0 )) return
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

        if (this.gestures.current == 'tap')
            this.gestures.current = undefined
    }

    onGesture( event ) 
    {
        console.log( `tap` )
    }

    
    destroy()
    {
        this.gestures.removeEventListener('tap', this.listener)
        this.listener   = null
        this.gestures   = null
        this.parameters = null
        this.start      = null
        this.current    = null
        this.end        = null
        this.userData   = null
        this.numTaps    = null

        console.log("Tap destroyed")
    }

}


Tap.MAX_END_DURATION = 150 // ms
Tap.MAX_END_DISTANCE = 10 // mm
