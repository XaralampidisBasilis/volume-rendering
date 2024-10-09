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

        // compute the volume intensities that are above the threshold
        const condition = tf.tidy(() => this.viewer.tensors.volume.squeeze().greater([this.threshold]))

        // compute the coordinates of volumed intensities greater than threshold
        const coordinates = await tf.whereAsync(condition)
        condition.dispose()

        // find the box min and max coordinates 
        const boxMin4 = tf.tidy(() => coordinates.min(0))
        const boxMax4 = tf.tidy(() => coordinates.max(0))
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

        console.log([this.min, this.max])

        return { min: this.min, max: this.max}
    }

    // async compute()
    // {   
    //     // remove the last singular dimension
    //     const volume = this.viewer.tensors.volume.squeeze()
    //     let boxMin = this.parameters.volume.dimensions.toArray()
    //     let boxMax = [0, 0, 0]
        
    //     for (let n = 0; n < volume.shape[0]; n++)
    //     {
    //         let slice = volume.slice(n)

    //         let condition = slice.greater([this.threshold])
    //         let coordinates = await tf.whereAsync(condition)
    //         condition.dispose()
    //         await tf.nextFrame()

    //         let tempMin = await coordinates.min(0).array()
    //         let tempMax = await coordinates.max(0).array()
    //         coordinates.dispose()
    //         await tf.nextFrame()

    //         tempMin.forEach((x, i) => { boxMin[i] = Math.min(x, boxMin[i]) })
    //         tempMax.forEach((x, i) => { boxMax[i] = Math.max(x, boxMax[i]) })
    //     }

    //     volume.dispose()
        
    //     boxMin = boxMin.toReverse().map((x, i) => 
    //     {
    //         return ( (x + 0) / this.parameters.volume.dimensions.getComponent(i)) * this.parameters.volume.size.getComponent(i)
    //     })  
        
    //     boxMax = boxMax.toReverse().map((x, i) => 
    //     {
    //         return ( (x + 1) / this.parameters.volume.dimensions.getComponent(i)) * this.parameters.volume.size.getComponent(i)
    //     })   
    
    //     // get the results
    //     this.min = new THREE.Vector3().fromArray(boxMin)
    //     this.max = new THREE.Vector3().fromArray(boxMax)

    //     return { min: this.min, max: this.max}
    // }

    dispose()
    {
        this.min = null
        this.max = null
        this.viewer = null
        this.parameters = null
        this.threshold = null
    }
}