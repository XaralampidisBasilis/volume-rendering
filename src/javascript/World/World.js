import * as THREE from 'three'
import Experience from '../Experience'
import MPRViewer from './MPRViewer/MPRViewer'
import EventEmitter from '../Utils/EventEmitter'

export default class World extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.camera = this.experience.camera

        // Wait for resources
        this.resources.on('ready', () =>
        {
            this.viewer = new MPRViewer()
            this.viewer.on('ready', () => 
            {
                this.trigger('ready')
            })
        })
    }

    update()
    {
        if (this.viewer)
        {
            this.viewer.update()
        }
    }

    destroy()
    {
        // dispose scene
        this.scene.traverse((child) =>
        {
            // test if it's a mesh
            if(child instanceof THREE.Mesh)
            {
                child.geometry.dispose()

                // Loop through the material properties
                for(const key in child.material)
                {
                    const value = child.material[key]

                    // Test if there is a dispose function
                    if(value && typeof value.dispose === 'function')
                    {
                        value.dispose()
                    }
                }
            }
        })

        this.scene = null
        this.camera = null
        this.resources = null
        this.experience = null

        console.log('World destroyed')
    }
}