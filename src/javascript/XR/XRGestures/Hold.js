import XRGestures from './XRGestures'

export default class Hold 
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
        
        this.gestures.inventory.hold = this 
        this.gestures.addEventListener( 'hold', (event) => this.onGesture( event ) )        
    }

    detectGesture() {        

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.detector.numConnected === 1 ) ) return
            if ( ! ( this.parameters[0].pathDistance < Hold.MAX_START_PATH_DISTANCE ) ) return
            if ( ! ( this.parameters[0].duration > Hold.MIN_START_DURATION ) ) return

            this.detector.gesture = 'hold'

            this.gestures.dispatchEvent( { type: 'hold', start: true, userData: this.userData, } ) 
            this.gestures.resetGesturesExcept( 'hold' )
            this.startGesture()
        } 

        if ( this.current ) {        

            this.dispatchEvent( { type: 'hold', current: true, userData: this.userData, } ) 

            if ( this.detector.numConnected > 1 ) this.resetGesture()
            if ( this.detector.numConnected === 0 ) this.endGesture()

        } 
        
        if ( this.end ) {            

            this.gestures.dispatchEvent( { type: 'hold', end: true, userData: this.userData, } )
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

        if (this.detector.gesture == 'hold')
            this.detector.gesture = undefined
    }

    onGesture( event ) {

        if ( event.start )   console.log( `hold start` )
        if ( event.current ) console.log( `hold current` )
        if ( event.end )     console.log( `hold end` )

    }

}

Hold.MIN_START_DURATION = 500 // ms
Hold.MAX_START_PATH_DISTANCE = 3 // mm
