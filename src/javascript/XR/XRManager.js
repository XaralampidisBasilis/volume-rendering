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
            this.setGestures()          
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

    setGestures()
    {
        this.gestures = new XRGestures(this.renderer.instance)
        this.gestures.addEventListener('polytap', (event) => this.onPolytap(event))
        this.gestures.addEventListener('hold',    (event) => this.onHold(event))
        this.gestures.addEventListener('pan',     (event) => this.onPan(event))
        this.gestures.addEventListener('swipe',   (event) => this.onSwipe(event))
        this.gestures.addEventListener('pinch',   (event) => this.onPinch(event))
        this.gestures.addEventListener('twist',   (event) => this.onTwist(event))
        this.gestures.addEventListener('implode', (event) => this.onImplode(event))
        this.gestures.addEventListener('explode', (event) => this.onExplode(event))
    }

    onPolytap(event)
    {
        // if (event.numTaps === 2)
        // {
        //     this.world.viewer.mesh.visible = true
        //     this.world.viewer.mesh.position.setFromMatrixPosition(this.reticle.mesh.matrix)
        // }

    }

    onSwipe(event) 
    {

    }

    onHold(event)
    {

    }

    onPan(event)
    {

    }

    onPinch(event)
    {

    }

    onImplode(event)
    {

    }

    onTwist(event)
    {

    }

    onExplode(event)
    {
        
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
        this.renderer.domElement.style.display = ''
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