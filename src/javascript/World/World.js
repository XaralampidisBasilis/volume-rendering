import * as THREE from 'three'
import Experience from '../Experience'
import ISOViewer from './ISOViewer/ISOViewer'
import EventEmitter from '../Utils/EventEmitter'

/**
 * World
 * 
 * Manages the 3D scene, including the main viewer and related resources.
 */
export default class World extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.camera = this.experience.camera
        this.viewer = new ISOViewer()
    }

    start()
    {
        this.viewer.start()
        this.scene.add(this.viewer.mesh)
        this.camera.instance.position.copy(this.viewer.size)
    }

    change(event)
    {
        this.viewer.change(event)
    }

    destroy()
    {
        this.destroyScene()

        this.viewer?.destroy()

        // Nullify references for cleanup
        this.viewer = null
        this.camera = null
        this.resources = null
        this.experience = null

        console.log('World destroyed')
    }

    destroyScene()
    {
        // Dispose of all meshes and their resources in the scene
        this.scene.traverse((child) =>
        {
            // Test if it's a mesh
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
    }

}
