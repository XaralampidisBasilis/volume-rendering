import XRGestures from './XRGestures'

export default class Swipe 
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
        
        this.direction  = undefined
        this.directions = [ 'RIGHT', 'UP', 'LEFT', 'DOWN'] 

        this.gestures.addEventListener( 'swipe', (event) => this.onGesture( event ) )        
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.detector.numControllers === 1 )) return
            if ( ! ( this.parameters[0].pathDistance > Swipe.MIN_START_PATH_DISTANCE )) return
            if ( ! ( this.parameters[0].pathSpeed > Swipe.MIN_START_PATH_SPEED )) return

            this.startGesture()

        }

        if ( this.current ) {

            if ( this.detector.numControllers === 0 ) {

                this.detector.gesture = 'swipe'

                this.gestures.resetGesturesExcept('swipe')
                this.endGesture()

            }
           
        }

        if ( this.end ) { 

            let index = this.gestures.sectorFromAngle( this.parameters[0].angle, 4 )
            this.direction = this.directions[index]   

            this.gestures.dispatchEvent( { type: 'swipe', start: true, current: true, end: true, direction: this.direction, userData: this.userData } )
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

        if (this.detector.gesture == 'swipe')
            this.detector.gesture = undefined
    }

    onGesture( event ) {
        
        console.log( `swipe ${ event.direction }` )        

    }

}

Swipe.MIN_START_PATH_DISTANCE = 3 // mm
Swipe.MIN_START_PATH_SPEED = 0.08 // m/s