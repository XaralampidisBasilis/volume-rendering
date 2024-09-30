import XRGestures from './XRGestures'

export default class Polytap 
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

        this.timeoutID = undefined
        this.numTaps = 0
        
        this.gestures.addEventListener( 'polytap', (event) => this.onGesture( event ) )        
    }

    detectGesture() {  

        if ( ! this.start ) {

            if ( ! ( this.detector.gesture === undefined )) return
            if ( ! ( this.gestures.inventory.tap.numTaps === 1 )) return        

            this.detector.gesture = 'polytap'

            this.numTaps = this.gestures.inventory.tap.numTaps
            this.timeoutID = setTimeout( () => this.endGesture(), Polytap.MAX_TAP_DURATION )

            this.dispatchEvent( { type: 'polytap', start: true, numTaps: this.numTaps, userData: this.userData } ) 
            this.startGesture()

        }

        if ( this.current ) {          

            this.dispatchEvent( { type: 'polytap', current: true, numTaps: this.numTaps, userData: this.userData } ) 

            // break condition
            if ( this.detector.numConnected > 1 ) { 
              
                clearTimeout( this.timeoutID )
                this.resetGesture()   

                this.gestures.inventory.tap.numTaps = 0 
                this.numTaps = 0            

            }

            // refresh condition
            if ( this.gestures.inventory.tap.numTaps > this.numTaps ) {

                clearTimeout( this.timeoutID )

                this.numTaps = this.gestures.inventory.tap.numTaps
                this.timeoutID = setTimeout( () => this.endGesture(), Polytap.MAX_TAP_DURATION )

            }
        }

        if ( this.end ) {

            this.gestures.dispatchEvent( { type: 'polytap', end: true, numTaps: this.numTaps, userData: this.userData } ) 
            this.gestures.delayDetector( XRGestures.DELAY_DETECTOR ) 
            this.gestures.resetGestures()

            this.detector.tap.numTaps = 0
            this.numTaps = 0 

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

        if (this.detector.gesture == 'polytap')
            this.detector.gesture = undefined

    }

    onGesture( event ) {

        if ( event.start )   console.log( `polytap start ${ event.numTaps }` )
        if ( event.current ) console.log( `polytap current ${ event.numTaps }` )
        if ( event.end )     console.log( `polytap end ${ event.numTaps }` )

    }

}

Polytap.MAX_TAP_DURATION = 230 // ms
