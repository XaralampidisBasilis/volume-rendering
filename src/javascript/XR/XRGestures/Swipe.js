import XRGestures from './XRGestures'

export default class Swipe 
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
        this.direction  = undefined
        this.directions = [ 'RIGHT', 'UP', 'LEFT', 'DOWN'] 
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'swipe', this.listener )   
    }

    detectGesture() {

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined )) return
            if ( ! ( this.gestures.numControllers === 1 )) return
            if ( ! ( this.parameters[0].pathDistance > Swipe.MIN_START_PATH_DISTANCE )) return
            if ( ! ( this.parameters[0].pathSpeed > Swipe.MIN_START_PATH_SPEED )) return

            this.startGesture()

        }

        if ( this.current ) {

            if ( this.gestures.numControllers === 0 ) {

                this.gestures.current = 'swipe'

                this.gestures.resetGesturesExcept('swipe')
                this.endGesture()

            }
           
        }

        if ( this.end ) { 

            let index = this.gestures.sectorFromAngle( this.parameters[0].angle, 4 )
            this.direction = this.directions[index]   

            this.gestures.dispatchEvent( { type: 'swipe', start: true, current: true, end: true, direction: this.direction, userData: this.userData } )
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

        if (this.gestures.current == 'swipe')
            this.gestures.current = undefined
    }

    onGesture( event ) 
    {
        console.log( `swipe ${ event.direction }` )        
    }

    destroy()
    {
        this.gestures.removeEventListener('swipe', this.listener)
        this.listener   = null
        this.gestures   = null
        this.parameters = null
        this.start      = null
        this.current    = null
        this.end        = null
        this.userData   = null
        this.direction  = null
        this.directions = null

        console.log("Swipe destroyed")
    }

}

Swipe.MIN_START_PATH_DISTANCE = 3 // mm
Swipe.MIN_START_PATH_SPEED = 0.08 // m/s