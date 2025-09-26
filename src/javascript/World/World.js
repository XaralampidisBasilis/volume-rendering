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

        // // Wait for viewer to be ready before positioning the camera
        // this.viewer.on('ready', () =>
        // {
        //     this.camera.instance.position.copy(this.viewer.computes.intensityMap.size)
        //     this.trigger('ready')
        // })
    }

    start()
    {
        
    }

    change(event)
    {

    }

    destroy()
    {
        this.disposeScene()

        // Clean up the viewer
        if (this.viewer)
        {
            this.viewer.destroy()
            this.viewer = null
        }

        // Nullify references for cleanup
        this.scene = null
        this.camera = null
        this.resources = null
        this.experience = null

        console.log('World destroyed')
    }

    disposeScene()
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
    }

}
