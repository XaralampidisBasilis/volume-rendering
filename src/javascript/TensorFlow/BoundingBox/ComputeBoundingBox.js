import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeBoundingBox
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            const spacing = this.parameters.volume.spacing.toArray()
            const condition = this.viewer.tensors.volume.greater([this.threshold])

            const [minIndX, maxIndX] = this.argRange(condition, 2)
            const [minIndY, maxIndY] = this.argRange(condition, 1)
            const [minIndZ, maxIndZ] = this.argRange(condition, 0)

            const minCoords = tf.stack([minIndX, minIndY, minIndZ], 0)    
            const maxCoords = tf.stack([maxIndX, maxIndY, maxIndZ], 0)  
            const minPosition = minCoords.mul(spacing)    
            const maxPosition = maxCoords.mul(spacing)   

            // get min max positions as vec3
            this.minCoords = new THREE.Vector3().fromArray(minCoords.arraySync())
            this.maxCoords = new THREE.Vector3().fromArray(maxCoords.arraySync())
            this.minPosition = new THREE.Vector3().fromArray(minPosition.arraySync())
            this.maxPosition = new THREE.Vector3().fromArray(maxPosition.arraySync())
        })

        return { minCoords: this.minCoords, minCoords: this.minCoords, minPosition: this.minPosition, maxPosition: this.maxPosition }
    }

    dataSync()
    { 
        this.viewer.material.uniforms.u_occupancy.value.min_coords.copy(this.minCoords)
        this.viewer.material.uniforms.u_occupancy.value.max_coords.copy(this.maxCoords)
        this.viewer.material.uniforms.u_occupancy.value.min_position.copy(this.minPosition)
        this.viewer.material.uniforms.u_occupancy.value.max_position.copy(this.maxPosition)
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    destroy()
    {
        this.viewer = null
        this.parameters = null
        this.threshold = null
        this.minCoords = null
        this.maxCoords = null
        this.minPosition = null
        this.maxPosition = null
    }

    // helper tensor functions

    argRange(tensor, axis)
    {
        const axes = [0, 1, 2, 3].toSpliced(axis, 1)
        const dimension = tensor.shape[axis]
        const condition = tensor.any(axes)
        const minInd = condition.argMax(0)
        const maxInd = tf.sub(dimension, condition.reverse().argMax(0))
        condition.dispose()
        return [minInd, maxInd] 
    }
}