import * as THREE from 'three'
import Reticle from './Reticle.js'
import EventEmitter from '../Utils/EventEmitter'

export default class HitTest extends EventEmitter
{
    constructor(renderer)
    {
        super()

        this.renderer = renderer
       
        this.setReticle()

        this.on('ready', this.onHitReady.bind(this))        
        this.on('empty', this.onHitEmpty.bind(this))

        this.renderer.xr.addEventListener('sessionstart', this.onSessionStart.bind(this))
    }

    setReticle()
    {
        this.reticle = new Reticle()
        this.reticle.mesh.visible = false
        this.reticle.mesh.matrixAutoUpdate = false
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

    onSessionStart()
    {
        this.session = this.renderer.xr.getSession()
        this.session.addEventListener('end', this.onSessionEnd.bind(this))
    }
   
    onSessionEnd()
    {
        this.session = null
        this.referenceSpace = null
        this.sourceRequested = false
        this.source = null
        this.result = null              
        this.pose = null
        this.matrix = null
    }

    update()
    {
        if (this.session) 
            this.session.requestAnimationFrame(this.updateFrame.bind(this))
    }

    updateFrame(timestamp, frame)
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
            })
            .catch((error) => {
                console.error('Error requesting hit test source:', error);
            })

        this.sourceRequested = true
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
