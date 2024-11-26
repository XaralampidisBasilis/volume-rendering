import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from '../../../../Utils/TensorUtils'

// assumes intensity data 3D, and data3DTexture
export default class ComputeQuantization
{   
    constructor(tensor)
    {
        this.tensor = tensor
    }

    async compute()
    {
        console.time('quantization')
        tf.tidy(() =>
        {
            const channels = tf.unstack(this.tensor)

            const distribution = TensorUtils.distribution(tensor, 256)

            const mappedSlices = channels.map(value => value.mul(2)) 
            return tf.stack(mappedSlices)
           
        })
        console.timeEnd('quantization')
    }

    dataSync()
    {
        this.viewer.tensors.volume.dispose()
        this.viewer.tensors.volume = this.tensor

        this.parameters.volume.tensorShape   = this.viewer.tensors.volume.shape.map((x) => x)
        this.parameters.volume.count         = this.parameters.volume.dimensions.toArray().reduce((product, value) => product * value, 1)
        this.parameters.volume.spacing       = new THREE.Vector3().copy(this.parameters.volume.size).divide(this.parameters.volume.dimensions)
        this.parameters.volume.invSpacing    = new THREE.Vector3(1, 1, 1).divide(this.parameters.volume.spacing)
        this.parameters.volume.invDimensions = new THREE.Vector3(1, 1, 1).divide(this.parameters.volume.dimensions)
    }

    destroy()
    {
        this.viewer = null
        this.parameters = null
        this.renderer = null
        this.tensor = null
    }
}