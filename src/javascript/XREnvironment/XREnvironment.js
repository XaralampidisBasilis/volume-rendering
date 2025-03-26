import * as THREE from 'three'
import Experience from '../Experience'
import XRHitTest from './XRHitTest'
import XRGestures from './XRGestures/XRGestures'
import * as XRActions from './XRActions/XRActions'
import { ARButton } from 'three/examples/jsm/webxr/ARButton'

export default class XREnvironment
{
    static instance = null

    constructor()
    {
        // Singleton
        if (XREnvironment.instance) 
        {
            return XREnvironment.instance
        }
        XREnvironment.instance = this

        // Setup
        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.world = this.experience.world
        this.scene = this.experience.scene
        this.gestures = new XRGestures()
        this.hitTest = new XRHitTest()

        this.setButton()
        this.setListeners()
        this.setActions()
    } 

    setButton()
    {
        this.button = ARButton.createButton(this.renderer.instance, 
        { 
            requiredFeatures: ['hit-test'],
            optionalFeatures: ['dom-overlay'],            
            domOverlay: { root: document.body } //{ root: document.getElementById('container-xr') },
        })
        
        document.body.appendChild(this.button)
    }

    setListeners()
    {
        this.sessionStartListener = () => this.onSessionStart()
        this.sessionEndListener = () => this.onSessionEnd()
        this.renderer.instance.xr.addEventListener('sessionstart', this.sessionStartListener)
        this.renderer.instance.xr.addEventListener('sessionend', this.sessionEndListener)
    }

    onSessionStart()
    {
        this.session = this.renderer.instance.xr.getSession()  
        
        this.renderer.instance.setClearAlpha(0)
        this.renderer.instance.domElement.style.display = 'none'
        this.hitTest.reticle.mesh.visible = true    

        // this.scene.traverse((child) =>
        // {
        //     if(child instanceof THREE.Mesh)
        //         child.visible = false
        // })
        
    }

    onSessionEnd()
    {
        this.renderer.instance.setClearAlpha(1)
        this.renderer.instance.domElement.style.display = ''
        this.hitTest.reticle.mesh.visible = false     

        // this.scene.traverse((child) =>
        // {
        //     if(child instanceof THREE.Mesh)
        //         child.visible = true
        // })  
    }

    setActions()
    {
        this.anchorViewer = new XRActions.Anchor(this.world.viewer)
        this.grabViewer = new XRActions.Grab(this.world.viewer, 'hold')
        this.transportViewer = new XRActions.ParallelTransport(this.world.viewer, 'pan')
        this.rollViewer = new XRActions.Roll(this.world.viewer, 'twist')
        this.scaleViewer = new XRActions.Scale(this.world.viewer, 'pinch')
        // this.guidedRotation = new XRActions.GuidedRotation(this.world.viewer, 'hold', new THREE.Vector3(), new THREE.Vector3(0, 0, 1))
        // this.guidedRotation2 = new XRActions.GuidedRotation2(this.world.viewer, 'hold', new THREE.Vector3(), new THREE.Vector3(0, 0, 1))
        // this.guidedRotation3 = new XRActions.GuidedRotation3(this.world.viewer, 'hold', new THREE.Vector3(), new THREE.Vector3(0, 0, 1))
        // this.guidedTranslation = new XRActions.GuidedTranslation(this.world.viewer, 'hold', new THREE.Vector3(), new THREE.Vector3(1, 0, 0))
    }

    update()
    {       
        if (this.session) 
            this.session.requestAnimationFrame(this.render.bind(this))
    }

    render(timestamp, frame)
    {
        this.hitTest.update(timestamp, frame)
        this.gestures.update()  
        this.renderer.update()
    }

    destroy()
    {
        // Remove event listeners for XR session events
        if (this.renderer.instance.xr) {
            this.renderer.instance.xr.removeEventListener('sessionstart', this.sessionStartListener)
            this.renderer.instance.xr.removeEventListener('sessionend', this.sessionEndListener)
        }

        // Clean up the hit test system
        if (this.hitTest) {
            this.hitTest.destroy() 
            this.hitTest = null
        }

        // Clean up the gestures system
        if (this.gestures) {
            this.gestures.destroy()
            this.gestures = null
        }

        // Remove the AR button from the DOM
        if (this.button && this.button.parentElement) {
            this.button.parentElement.removeChild(this.button)
            this.button = null
        }

        // Nullify references to other class properties to avoid memory leaks
        this.session = null
        this.experience = null
        this.resources = null
        this.renderer = null
        this.world = null
        this.scene = null

        console.log("XREnvironment destroyed")
    }

}