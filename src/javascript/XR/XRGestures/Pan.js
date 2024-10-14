import XRGestures from './XRGestures'

export default class Pan 
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
        this.gestures.addEventListener( 'pan', this.listener )
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined )) return
            if ( ! ( this.gestures.numControllers === 1 ) ) return
            if ( ! ( this.parameters[0].pathDistance > Pan.MIN_START_PATH_DISTANCE )) return
            if ( ! ( this.parameters[0].pathSpeed < Pan.MAX_START_PATH_SPEED )) return

            this.gestures.current = 'pan'     

            this.gestures.dispatchEvent( { type: 'pan', start: true, userData: this.userData, } ) 
            this.gestures.resetGesturesExcept('pan')
            this.startGesture()

        } 

        if ( this.current ) {  

            this.gestures.dispatchEvent( { type: 'pan', current: true, userData: this.userData, } ) 

            if ( this.gestures.numControllers === 2 ) this.resetGesture()
            if ( this.gestures.numControllers === 0 ) this.endGesture()        

        } 
        
        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'pan', end: true, userData: this.userData, } ) 
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

        if (this.gestures.current == 'pan')
            this.gestures.current = undefined
    }

    onGesture( event ) {
        
        if ( event.start )   console.log(`pan start`)
        if ( event.current ) console.log(`pan current`)
        if ( event.end )     console.log(`pan end`)

    }

    destroy() 
    {
        this.gestures.removeEventListener('pan', this.listener)
        this.listener = null
        this.gestures = null
        this.parameters = null
        this.start = null
        this.current = null
        this.end = null
        this.userData = null

        console.log("Pan destroyed")
    }

}

Pan.MIN_START_PATH_DISTANCE = 3 // mm
Pan.MAX_START_PATH_SPEED = 0.08 // m/s
