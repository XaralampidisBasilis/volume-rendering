import * as THREE from 'three'
import Experience from '../Experience'
import Reticle from './Reticle'
import EventEmitter from '../Utils/EventEmitter'

export default class HitTest extends EventEmitter
{
    constructor(renderer)
    {
        super()

        this.experience = new Experience()
        this.renderer = this.experience.renderer.instance
        this.scene = this.experience.scene

        this.setReticle()

        this.on('ready', this.onHitReady.bind(this))        
        this.on('empty', this.onHitEmpty.bind(this))

        this.renderer.xr.addEventListener('sessionstart', (event) => this.onSessionStart(event))
    }

    setReticle()
    {
        this.reticle = new Reticle()
        this.reticle.mesh.visible = false
        this.reticle.mesh.matrixAutoUpdate = false
        this.scene.add(this.reticle.mesh)
    }

    onHitReady()
    {
        this.reticle.mesh.visible = true;
        this.reticle.mesh.matrix.fromArray(this.matrix);
    }

    onHitEmpty()
    {
        this.reticle.mesh.visible = false;
    }

    onSessionStart(event)
    {
        this.session = this.renderer.xr.getSession()
        this.session.addEventListener('end', (event) => this.onSessionEnd(event))
    }
   
    onSessionEnd(event)
    {
        this.session = null
        this.referenceSpace = null
        this.sourceRequested = false
        this.source = null
        this.result = null              
        this.pose = null
        this.matrix = null
        this.scene.remove(this.reticle.mesh)
    }

    update(timestamp, frame)
    {
        if (frame)
        {
            if (!this.sourceRequested)
                this.requestSource()

            if (this.source)
                this.getResults(frame)
        }    
    }

    requestSource()
    {
        this.session.requestReferenceSpace('viewer')
            .then((referenceSpace) => {
                this.referenceSpace = referenceSpace
                return this.session.requestHitTestSource({ space: referenceSpace });
            })
            .then((source) => {
                this.source = source;
                this.sourceRequested = true
            })
            .catch((error) => {
                console.error('Error requesting hit test source:', error);
            })
    }

    getResults(frame) 
    {            
        const results = frame.getHitTestResults(this.source)

        if (results.length)
        {
            this.result = results[0]
            this.referenceSpace = this.renderer.xr.getReferenceSpace()

            if (this.result && this.referenceSpace) 
            {
                this.pose = this.result.getPose(this.referenceSpace)

                if (this.pose)
                {
                    this.matrix = this.pose.transform.matrix
                    this.trigger('ready')
                    return
                }                
            }               
        }
        
        this.trigger('empty')
    }   
       
}
