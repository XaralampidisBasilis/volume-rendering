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

            const [minX, maxX] = [conditionX.argMax(0), conditionX.reverse().argMax(0)]
            const [minY, maxY] = [conditionY.argMax(0), conditionY.reverse().argMax(0)]
            const [minZ, maxZ] = [conditionZ.argMax(0), conditionZ.reverse().argMax(0)]
            
            conditionX.dispose()
            conditionY.dispose()
            conditionZ.dispose()

            const min1 = tf.stack([minX, minY, minZ], 0)    
            const max1 = volumeDims.sub(tf.stack([maxX, maxY, maxZ], 0))
            const min = min1.mul(volumeSpacing)
            const max = max1.mul(volumeSpacing)

            // get the results
            this.min = new THREE.Vector3().fromArray(min.arraySync())
            this.max = new THREE.Vector3().fromArray(max.arraySync())
        })

        console.log([this.min, this.max])
        console.log(tf.memory())
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