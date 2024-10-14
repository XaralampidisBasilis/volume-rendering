import XRGestures from './XRGestures'

export default class Hold 
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
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'hold', this.listener )        
    }

    detectGesture() {        

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined )) return
            if ( ! ( this.gestures.numControllers === 1 ) ) return
            if ( ! ( this.parameters[0].pathDistance < Hold.MAX_START_PATH_DISTANCE ) ) return
            if ( ! ( this.parameters[0].duration > Hold.MIN_START_DURATION ) ) return

            this.gestures.current = 'hold'
            this.gestures.dispatchEvent( { type: 'hold', start: true, userData: this.userData, } ) 
            this.gestures.resetGesturesExcept( 'hold' )
            this.startGesture()
        } 

        if ( this.current ) {        

            this.gestures.dispatchEvent( { type: 'hold', current: true, userData: this.userData, } ) 

            if ( this.gestures.numControllers > 1 ) this.resetGesture()
            if ( this.gestures.numControllers === 0 ) this.endGesture()

        } 
        
        if ( this.end ) {            

            this.gestures.dispatchEvent( { type: 'hold', end: true, userData: this.userData, } )
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

        if (this.gestures.current == 'hold')
            this.gestures.current = undefined
    }

    onGesture( event ) 
    {
        if ( event.start )   console.log( `hold start` )
        if ( event.current ) console.log( `hold current` )
        if ( event.end )     console.log( `hold end` )

    }

    destroy()
    {
        this.gestures.removeEventListener('hold', this.listener)
        this.listener = null
        this.gestures = null
        this.parametersDual = null
        this.start    = null
        this.current  = null
        this.end      = null
        this.userData = null

        console.log("Hold destroyed")
    }
}

Hold.MIN_START_DURATION = 500 // ms
Hold.MAX_START_PATH_DISTANCE = 3 // mm
