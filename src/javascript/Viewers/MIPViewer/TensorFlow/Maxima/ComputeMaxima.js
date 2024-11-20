import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeMaxima
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.division = this.viewer.material.uniforms.u_maximap.value.division
    }

    async compute()
    {   
        console.time('computeMaxima')
        tf.tidy(() => 
        {
            const divisions = new Array(3).fill(this.division)
            const spacing = this.parameters.volume.spacing.toArray().toReversed().concat(1)
            const volume = this.viewer.tensors.volume;

            // compute the occupancy density of each block  
            const volumeMaxima = tf.maxPool3d(volume, divisions, divisions, 'same')
            
            // convert normalized values to uint8 255
            const maximap = volumeMaxima.mul([255])
            volumeMaxima.dispose()
      
            this.maximap = {
                data      : new Uint8Array(maximap.dataSync()),
                dimensions: maximap.shape.slice(0, 3).toReversed(),
                size      : maximap.shape.map((dim, i) => spacing[i] * dim).slice(0, 3).toReversed(),
                spacing   : spacing.map((space) => this.division * space).slice(0, 3).toReversed(),
            }
        })
        this.dataSync()
        console.timeEnd('computeMaxima')
    }

    dataSync()  
    {
        if (this.viewer.textures.maximap) 
            this.viewer.textures.maximap.dispose()

        this.viewer.textures.maximap = new THREE.Data3DTexture(this.maximap.data, ...this.maximap.dimensions)     
        this.viewer.textures.maximap.type = THREE.UnsignedByteType
        this.viewer.textures.maximap.format = THREE.RedFormat
        this.viewer.textures.maximap.wrapS = THREE.ClampToEdgeWrapping
        this.viewer.textures.maximap.wrapT = THREE.ClampToEdgeWrapping
        this.viewer.textures.maximap.wrapR = THREE.ClampToEdgeWrapping
        this.viewer.textures.maximap.minFilter = THREE.LinearFilter
        this.viewer.textures.maximap.magFilter = THREE.LinearFilter
        this.viewer.textures.maximap.needsUpdate = true

        this.viewer.material.uniforms.u_maximap.value.dimensions.fromArray(this.maximap.dimensions)
        this.viewer.material.uniforms.u_maximap.value.inv_dimensions.fromArray(this.maximap.dimensions.map((dim) => 1/dim))
        this.viewer.material.uniforms.u_maximap.value.spacing.fromArray(this.maximap.spacing)
        this.viewer.material.uniforms.u_maximap.value.size.fromArray(this.maximap.size)

        this.viewer.material.uniforms.u_textures.value.maximap = this.viewer.textures.maximap
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.division = this.viewer.material.uniforms.u_maximap.value.division
    }

    destroy() 
    {
        this.data = null;
        this.maximap = null;
        this.viewer = null;
        this.parameters = null;

        console.log('ComputeOccupancy destroyed and resources freed.');
    }
}