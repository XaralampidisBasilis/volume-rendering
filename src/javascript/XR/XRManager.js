import * as THREE from 'three'
import Experience from '../Experience'
import HitTest from './HitTest'
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
            this.setButton()
            this.setHitTest()
            this.gestures = new XRGestures(this.renderer.instance)
            this.renderer.instance.xr.addEventListener('sessionstart', (event) => this.onSessionStart(event))
            this.renderer.instance.xr.addEventListener('sessionend', (event) => this.onSessionEnd(event))
        })

    } 

    setButton()
    {
        this.button = ARButton.createButton(this.renderer.instance, 
        { 
            requiredFeatures: ['hit-test'],
            optionalFeatures: ['dom-overlay', 'dom-overlay-for-handheld-ar'],            
            domOverlay: { root: document.getElementById('container-xr') },
        })

        this.button.addEventListener('click', this.onButton.bind(this))
        document.body.appendChild(this.button)
    }

    setHitTest()
    {
        this.hitTest = new HitTest()
        this.reticle = this.hitTest.reticle
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

    onButton()
    {

    }

    onSessionStart(event)
    {
        this.session = this.renderer.instance.xr.getSession()  
        this.renderer.instance.setClearAlpha(0)
        this.renderer.instance.domElement.style.display = 'none'
        this.reticle.mesh.visible = false     
        this.scene.traverse((child) =>
        {
            if(child instanceof THREE.Mesh)
            {
                child.visible = false
            }
        })
    }

    onSessionEnd(event)
    {
        this.renderer.instance.setClearAlpha(1)
        this.renderer.instance.domElement.style.display = ''
        this.reticle.mesh.visible = false     
        this.scene.traverse((child) =>
            {
                if(child instanceof THREE.Mesh)
                {
                    child.visible = true
                }
            })  
    }
}