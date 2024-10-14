    import * as THREE from 'three'
    import Experience from '../Experience'
    import Reticle from './Reticle'
    import EventEmitter from '../Utils/EventEmitter'

    export default class XRHitTest extends EventEmitter
    {
        constructor()
        {
            super()

            this.experience = new Experience()
            this.renderer = this.experience.renderer.instance
            this.scene = this.experience.scene
            this.setReticle()

            this.on('ready', () => this.onHitReady())        
            this.on('empty', () => this.onHitEmpty())
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
            this.reticle.mesh.visible = true
            this.reticle.mesh.matrix.fromArray(this.matrix)
        }

        onHitEmpty()
        {
            this.reticle.mesh.visible = false
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
            this.session = this.experience.xr.session
            this.session.requestReferenceSpace('viewer')
                .then((referenceSpace) => {
                    this.referenceSpace = referenceSpace
                    return this.session.requestHitTestSource({ space: referenceSpace })
                })
                .then((source) => {
                    this.source = source
                    this.sourceRequested = true
                })
                .catch((error) => {
                    console.error('Error requesting hit test source:', error)
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

        destroy()
        {
            this.off('ready')        
            this.off('empty')

            if (this.reticle) {
                this.scene.remove(this.reticle.mesh)
                this.reticle.destroy()
                this.reticle = null
            }

            this.referenceSpace = null
            this.sourceRequested = false
            this.source = null
            this.result = null              
            this.pose = null
            this.matrix = null

            console.log("XRHitTest destroyed")
        }
        
    }
