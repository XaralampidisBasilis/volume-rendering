import * as THREE from 'three'
import Experience from '../Experience'
import { TransformControls } from 'three/addons/controls/TransformControls.js';

export default class Controls 
{
    constructor()
    {
        this.experience = new Experience()
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.scene = this.experience.scene

        this.setInstance()
        this.setGizmo()
        this.setKeybinds()

        this.instance.addEventListener('dragging-changed', (event) => 
        {
            this.camera.orbit.enabled = ! event.value
        } )
    }

    setInstance()
    {
        this.instance = new TransformControls(this.camera.instance, this.renderer.instance.domElement)
        this.instance.setSpace('local')
    }

    setGizmo()
    {
        this.gizmo = this.instance.getHelper()
        this.scene.add(this.gizmo)
    }

    setKeybinds()
    {
        window.addEventListener( 'keydown', (event) => 
        {
            switch ( event.key ) 
            {
                case 'q':
                    this.instance.setSpace( this.instance.space === 'local' ? 'world' : 'local' )
                    break

                case 't':
                    this.instance.setMode( 'translate' )
                    break

                case 'r':
                    this.instance.setMode( 'rotate' )
                    break

                case '+':
                case '=':
                    this.instance.setSize( this.instance.size + 0.1 )
                    break

                case '-':
                case '_':
                    this.instance.setSize( Math.max( this.instance.size - 0.1, 0.1 ) )
                    break

                case 'x':
                    this.instance.showX = ! this.instance.showX
                    break

                case 'y':
                    this.instance.showY = ! this.instance.showY
                    break

                case 'z':
                    this.instance.showZ = ! this.instance.showZ
                    break

                case 'v':
                    this.instance.showX = ! this.instance.showX
                    this.instance.showY = ! this.instance.showY
                    this.instance.showZ = ! this.instance.showZ
                    break

                case 'e':
                    this.instance.enabled = ! this.instance.enabled
                    break

                case 'Escape':
                    this.instance.reset()
                    break
            }

        } )
    }
}