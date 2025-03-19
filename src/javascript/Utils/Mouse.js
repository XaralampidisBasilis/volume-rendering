import * as THREE from 'three';
import EventEmitter from './EventEmitter'

export default class Mouse extends EventEmitter
{
    constructor()
    {
        super()

        // Initial mouse position
        this.screenPosition = new THREE.Vector2()

        // Normalized mouse position (-1 to 1 range)
        this.ndcPosition = new THREE.Vector2()

        // Bind event handlers to the instance
        this.onMouseMove = this.onMouseMove.bind(this)
        this.onMouseDown = this.onMouseDown.bind(this)
        this.onMouseUp = this.onMouseUp.bind(this)

        // Add event listeners
        window.addEventListener('mousemove', this.onMouseMove)
        window.addEventListener('mousedown', this.onMouseDown)
        window.addEventListener('mouseup', this.onMouseUp)
    }

    onMouseMove(event)
    {
        // Update mouse position
        this.screenPosition.x = event.clientX
        this.screenPosition.y = event.clientY

        // Update normalized mouse position
        this.ndcPosition.x = (this.screenPosition.x / window.innerWidth) * 2 - 1
        this.ndcPosition.y = (-this.screenPosition.y / window.innerHeight) * 2 - 1

        // Emit the `move` event
        this.trigger('move', 
        {
            x: this.screenPosition.x,
            y: this.screenPosition.y,
            ndcX: this.ndcPosition.x,
            ndcY: this.ndcPosition.y,
        })

        // console.log('mousemove', this)
    }

    onMouseDown(event)
    {
        // Emit the `down` event with button information
        this.trigger('down', {
        
            button: event.button,
            x: this.screenPosition.x,
            y: this.screenPosition.y,
            ndcX: this.ndcPosition.x,
            ndcY: this.ndcPosition.y,
        })

        // console.log('mousedown', this)
    }

    onMouseUp(event)
    {
        // Emit the `up` event with button information
        this.trigger('up', 
        {
            button: event.button,
            x: this.screenPosition.x,
            y: this.screenPosition.y,
            ndcX: this.ndcPosition.x,
            ndcY: this.ndcPosition.y,
        })

        // console.log('mouseup', this)
    }

    destroy() 
    {
        // Remove event listeners
        window.removeEventListener('mousemove', this.onMouseMove)
        window.removeEventListener('mousedown', this.onMouseDown)
        window.removeEventListener('mouseup', this.onMouseUp)

        // Clear properties for cleanup
        this.screenPosition = null
        this.ndcPosition = null

        console.log('Mouse destroyed')
    }
}
