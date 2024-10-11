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
            const condition = this.viewer.tensors.volume.greater([this.threshold])

            const [minIndX, maxIndX] = this.argMinMax(condition, 2)
            const [minIndY, maxIndY] = this.argMinMax(condition, 1)
            const [minIndZ, maxIndZ] = this.argMinMax(condition, 0)

            const minInd = tf.stack([minIndX, minIndY, minIndZ], 0)    
            const maxInd = tf.stack([maxIndX, maxIndY, maxIndZ], 0)  

            const spacing = this.parameters.volume.spacing.toArray()
            const boxMin = minInd.mul(spacing)    
            const boxMax = maxInd.mul(spacing)   

            // get min max positions as vec3
            this.boxMin = new THREE.Vector3().fromArray(boxMin.arraySync())
            this.boxMax = new THREE.Vector3().fromArray(boxMax.arraySync())
        })

        return { boxMin: this.boxMin, boxMax: this.boxMax}
    }

    
    dataSync()
    { 
        this.viewer.material.uniforms.u_occupancy.value.box_min.copy(this.boxMin)
        this.viewer.material.uniforms.u_occupancy.value.box_max.copy(this.boxMax)
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    destroy()
    {
        this.boxMin = null
        this.boxMax = null
        this.viewer = null
        this.parameters = null
        this.threshold = null
    }

    // helper tensor functions

    argMinMax(boolTensor, axis)
    {
        const axes = [0, 1, 2, 3].toSpliced(axis, 1)
        const dimension = boolTensor.shape[axis]
        const condition = boolTensor.any(axes)
        let minInd = condition.argMax(0)
        let maxInd = condition.reverse().argMax(0)
        maxInd = tf.sub(dimension, maxInd)
        condition.dispose()
        return [minInd, maxInd] 

    }
}