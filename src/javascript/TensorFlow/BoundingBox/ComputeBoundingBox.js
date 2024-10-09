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
        // remove the last singular dimension
        const volume = this.viewer.tensors.volume.squeeze()

        // compute the volume intensities that are above the threshold
        const condition = volume.greater([this.threshold])
        volume.dispose()

        // compute the coordinates of volumed intensities greater than threshold
        const coordinates = await tf.whereAsync(condition)
        condition.dispose()

        // find the box min and max coordinates 
        const boxMin4 = coordinates.min(0)
        const boxMax4 = coordinates.max(0)
        coordinates.dispose()

        // reverse the coordinates because tensor flow uses the NHWC format by default
        const boxMin3 = boxMin4.reverse()
        const boxMax3 = boxMax4.reverse()
        boxMin4.dispose()
        boxMax4.dispose()

        // compute the box min and max positions in the world space 
        const boxMin2 = boxMin3.add([0])
        const boxMax2 = boxMax3.add([1])
        boxMin3.dispose()
        boxMax3.dispose()

        const boxMin1 = boxMin2.div(tf.tensor1d(this.parameters.volume.dimensions.toArray()))
        const boxMax1 = boxMax2.div(tf.tensor1d(this.parameters.volume.dimensions.toArray()))
        boxMin2.dispose()
        boxMax2.dispose()

        const boxMin = boxMin1.mul(tf.tensor1d(this.parameters.volume.size.toArray()))
        const boxMax = boxMax1.mul(tf.tensor1d(this.parameters.volume.size.toArray()))
        boxMin1.dispose()
        boxMax1.dispose()

        // get the results
        this.min = new THREE.Vector3().fromArray(await boxMin.array())
        this.max = new THREE.Vector3().fromArray(await boxMax.array())
        boxMin.dispose()
        boxMax.dispose()

        return { min: this.min, max: this.max}
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