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
        console.time('computeBoundingBox')

        tf.tidy(() => 
        {
            const volumeDims = tf.tensor1d(this.parameters.volume.dimensions.toArray())
            const volumeSpacing = tf.tensor1d(this.parameters.volume.spacing.toArray())
            const volume = this.viewer.tensors.volume.squeeze()
            
            const condition = volume.greater([this.threshold])
            volume.dispose()

            const conditionX = condition.any([0, 1])
            const conditionY = condition.any([0, 2])
            const conditionZ = condition.any([1, 2])
            condition.dispose()

            const [minIndX, maxIndX] = [conditionX.argMax(0), conditionX.reverse().argMax(0)]
            const [minIndY, maxIndY] = [conditionY.argMax(0), conditionY.reverse().argMax(0)]
            const [minIndZ, maxIndZ] = [conditionZ.argMax(0), conditionZ.reverse().argMax(0)]
            
            conditionX.dispose()
            conditionY.dispose()
            conditionZ.dispose()

            const minInd = tf.stack([minIndX, minIndY, minIndZ], 0)    
            const maxInd = volumeDims.sub(tf.stack([maxIndX, maxIndY, maxIndZ], 0))
           
            const minPos = minInd.mul(volumeSpacing)
            const maxPos = maxInd.mul(volumeSpacing)

            // get the results
            this.min = new THREE.Vector3().fromArray(minPos.arraySync())
            this.max = new THREE.Vector3().fromArray(maxPos.arraySync())
        })

        console.timeEnd('computeBoundingBox')

        return { min: this.min, max: this.max}
    }

    restart()
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    update()
    { 
        this.viewer.material.uniforms.u_occupancy.value.box_min.copy(this.min)
        this.viewer.material.uniforms.u_occupancy.value.box_max.copy(this.max) 
    }

    dispose()
    {
        this.min = null
        this.max = null
        this.viewer = null
        this.parameters = null
        this.threshold = null
    }
}