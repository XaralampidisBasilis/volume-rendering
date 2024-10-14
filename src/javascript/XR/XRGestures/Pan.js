import XRGestures from './XRGestures'

export default class Pan 
{
    constructor()
    {
        this.gestures = new XRGestures()
        this.parameters = this.gestures.parameters
        this.detector = this.gestures.detector

        this.setGesture()
        this.addListener()
    }

    setGesture()
    {
        this.start    = false
        this.current  = false
        this.end      = false
        this.userData = {}
    }

    addListener()
    {
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'pan', this.listener )
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.detector.numControllers === 1 ) ) return
            if ( ! ( this.parameters[0].pathDistance > Pan.MIN_START_PATH_DISTANCE )) return
            if ( ! ( this.parameters[0].pathSpeed < Pan.MAX_START_PATH_SPEED )) return

            this.detector.gesture = 'pan'     

            this.gestures.dispatchEvent( { type: 'pan', start: true, userData: this.userData, } ) 
            this.gestures.resetGesturesExcept('pan')
            this.startGesture()

        } 

        if ( this.current ) {  

            this.gestures.dispatchEvent( { type: 'pan', current: true, userData: this.userData, } ) 

            if ( this.detector.numControllers === 2 ) this.resetGesture()
            if ( this.detector.numControllers === 0 ) this.endGesture()        

        } 
        
        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'pan', end: true, userData: this.userData, } ) 
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

        if (this.detector.gesture == 'pan')
            this.detector.gesture = undefined
    }

    onGesture( event ) {
        
        if ( event.start )   console.log(`pan start`)
        if ( event.current ) console.log(`pan current`)
        if ( event.end )     console.log(`pan end`)

    }

    destroy() 
    {
        this.gestures.removeEventListener('pan', this.listener)
        this.detector = null
        this.userData = null
        this.listener = null
        this.start = null
        this.current = null
        this.end = null
    }

}

Pan.MIN_START_PATH_DISTANCE = 3 // mm
Pan.MAX_START_PATH_SPEED = 0.08 // m/s
