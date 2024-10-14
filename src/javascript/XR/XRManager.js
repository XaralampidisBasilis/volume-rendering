import * as THREE from 'three'
import Experience from '../Experience'
import XRHitTest from './XRHitTest'
import XRGestures from './XRGestures/XRGestures'
import { ARButton } from 'three/examples/jsm/webxr/ARButton'

export default class XRManager
{
    constructor()
    {
        // Setup
        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.world = this.experience.world
        this.scene = this.experience.scene
        this.resources.on('ready', () =>
        {
            this.gestures = new XRGestures()
            this.hitTest = new XRHitTest()
            this.setButton()
            this.addSessionListeners()
        })
    } 

    setButton()
    {
        this.button = ARButton.createButton(this.renderer.instance, 
        { 
            requiredFeatures: ['hit-test'],
            optionalFeatures: ['dom-overlay'],            
            domOverlay: { root: document.getElementById('container-xr') },
        })
        
        document.body.appendChild(this.button)
    }

    addSessionListeners()
    {
        this.sessionStartListener = () => this.onSessionStart()
        this.sessionEndListener = () => this.onSessionEnd()
        this.renderer.instance.xr.addEventListener('sessionstart', this.sessionStartListener)
        this.renderer.instance.xr.addEventListener('sessionend', this.sessionEndListener)
    }

    update()
    {       
        if (this.session) 
            this.session.requestAnimationFrame(this.updateFrame.bind(this))
    }

    updateFrame(timestamp, frame)
    {
        this.gestures.update()  
        this.hitTest.update(timestamp, frame)
        this.renderer.update()
    }

    onSessionStart()
    {
        this.session = this.renderer.instance.xr.getSession()  
        
        this.renderer.instance.setClearAlpha(0)
        this.renderer.instance.domElement.style.display = 'none'
        this.scene.traverse((child) =>
        {
            if(child instanceof THREE.Mesh)
                child.visible = false
        })
        
        this.hitTest.reticle.mesh.visible = false    
    }

    onSessionEnd()
    {
        this.renderer.instance.setClearAlpha(1)
        this.renderer.instance.domElement.style.display = ''

        this.hitTest.reticle.mesh.visible = false     
        this.scene.traverse((child) =>
        {
            if(child instanceof THREE.Mesh)
                child.visible = true
        })  
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

        console.log("XRManager destroyed")
    }

}