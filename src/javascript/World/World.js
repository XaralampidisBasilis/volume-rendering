import * as THREE from 'three'
import Experience from '../Experience'
import EventEmitter from '../Utils/EventEmitter'
import MPRViewer from './MPRViewer/MPRViewer'

export default class World extends EventEmitter
{
    constructor()
    {   
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.camera = this.experience.camera
        this.viewer = new MPRViewer()

        // const geometry = new THREE.BoxGeometry(0.3, 0.3, 0.3); 
        // const material = new THREE.MeshNormalMaterial(); 
        // this.viewer = new THREE.Mesh( geometry, material ); 
        // this.scene.add(this.viewer)
    }

    update()
    {
        this.viewer.update()
    }

    destroy()
    {
        this.destroyScene()
        this.camera = null
        this.resources = null
        this.experience = null

        console.log('World destroyed')
    }

    destroyScene()
    {
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
    }
}