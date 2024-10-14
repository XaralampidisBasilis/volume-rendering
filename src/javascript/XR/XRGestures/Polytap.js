import XRGestures from './XRGestures'

export default class Polytap 
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
        this.timeoutID = undefined
        this.numTaps = 0
        this.listener = (event) => this.onGesture( event )
        this.gestures.addEventListener( 'polytap', this.listener )   
    }

    detectGesture() {  

        if ( ! this.start ) {

            if ( ! ( this.gestures.current === undefined )) return
            if ( ! ( this.gestures.inventory.tap.numTaps === 1 )) return        

            this.gestures.current = 'polytap'
            this.numTaps = this.gestures.inventory.tap.numTaps
            this.timeoutID = setTimeout( () => this.endGesture(), Polytap.MAX_TAP_DURATION )
            this.gestures.dispatchEvent( { type: 'polytap', start: true, numTaps: this.numTaps, userData: this.userData } ) 
            this.startGesture()

        }

        if ( this.current ) {          

            this.gestures.dispatchEvent( { type: 'polytap', current: true, numTaps: this.numTaps, userData: this.userData } ) 

            // break condition
            if ( this.gestures.numControllers > 1 ) { 
            
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
            this.gestures.delayGestures( XRGestures.DELAY_DETECTOR ) 
            this.gestures.resetGestures()
            this.gestures.inventory.tap.numTaps = 0
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

        if (this.gestures.current == 'polytap')
            this.gestures.current = undefined

    }

    onGesture( event ) {

        if ( event.start )   console.log( `polytap start ${ event.numTaps }` )
        if ( event.current ) console.log( `polytap current ${ event.numTaps }` )
        if ( event.end )     console.log( `polytap end ${ event.numTaps }` )

    }

    destroy()
    {
        if (this.timeoutID) 
            clearTimeout(this.timeoutID)

        this.gestures.removeEventListener('polytap', this.listener)
        this.listener   = null
        this.gestures   = null
        this.parameters = null
        this.start      = null
        this.current    = null
        this.end        = null
        this.userData   = null
        this.timeoutID  = null
        this.numTaps    = null

        console.log("Polytap destroyed")
    }

}

Polytap.MAX_TAP_DURATION = 230 // ms
