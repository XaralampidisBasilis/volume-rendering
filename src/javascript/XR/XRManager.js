import * as THREE from 'three'
import Experience from '../Experience.js'
import HitTest from './HitTest.js'
import XRGestures from './XRGestures/XRGestures.js'
import { XRButton } from 'three/examples/jsm/webxr/XRButton.js'

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

            this.renderer.instance.xr.addEventListener('sessionstart', this.onSessionStart.bind(this))
            this.renderer.instance.xr.addEventListener('sessionend', this.onSessionEnd.bind(this))
        })

    } 

    setButton()
    {
        this.button = XRButton.createButton(this.renderer.instance, { 
            mode: 'immersive-ar',
            sessionInit: {
                requiredFeatures: ['hit-test'],
                optionalFeatures: ['dom-overlay', 'dom-overlay-for-handheld-ar'],            
                domOverlay: { root: document.getElementById('container-xr') },
            }
        })

        // this.button.addEventListener('click', this.onButton.bind(this))

        document.body.appendChild(this.button)
    }

    setHitTest()
    {
        this.hitTest = new HitTest(this.renderer.instance)
        this.reticle = this.hitTest.reticle
        this.scene.add(this.reticle.mesh)
    }

    setGestures()
    {
        this.gestures = new XRGestures(this.renderer.instance)

        this.gestures.addEventListener('polytap', this.onPolytap.bind(this))
        this.gestures.addEventListener('hold', this.onHold.bind(this))
        this.gestures.addEventListener('pan', this.onPan.bind(this))
        this.gestures.addEventListener('swipe', this.onSwipe.bind(this))
        this.gestures.addEventListener('pinch', this.onPinch.bind(this))
        this.gestures.addEventListener('twist', this.onTwist.bind(this))
        this.gestures.addEventListener('implode', this.onImplode.bind(this))
        this.gestures.addEventListener('explode', this.onExplode.bind(this))
    }

    onPolytap(event)
    {
        if (event.numTaps === 2)
        {
            this.world.viewer.mesh.visible = true
            this.world.viewer.mesh.position.setFromMatrixPosition(this.reticle.mesh.matrix);
        }

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

    
    update()
    {       
        this.gestures.update()  
        this.hitTest.update()
    }

    
    onSessionStart()
    {
        this.renderer.instance.setClearAlpha(0)
        this.renderer.instance.domElement.style.display = 'none';

        this.reticle.mesh.visible = false     

        this.scene.traverse((child) =>
        {
            if(child instanceof THREE.Mesh)
            {
                child.visible = false
            }
        })
    }

    onSessionEnd()
    {
        this.renderer.instance.setClearAlpha(1)
        renderer.domElement.style.display = '';

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