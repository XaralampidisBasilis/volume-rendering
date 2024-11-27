import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeResizing
{   
    constructor(viewer)
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.renderer = this.viewer.renderer
        this.setCapabilities()
    }

    setCapabilities()
    {
        const textureCount = this.viewer.parameters.volume.count
        const maxTextureSize = this.renderer.instance.capabilities.maxTextureSize
        const maxTextureCount = maxTextureSize * maxTextureSize * 0.5
        const resizeDim3 = Math.min(Math.cbrt(maxTextureCount / textureCount), 1)
        const resizeDim2 = Math.min(Math.sqrt(maxTextureCount / textureCount), 1)

        this.parameters.volume.dimensions.x = Math.floor(this.parameters.volume.dimensions.x * resizeDim3)
        this.parameters.volume.dimensions.y = Math.floor(this.parameters.volume.dimensions.y * resizeDim3)
        this.parameters.volume.dimensions.z = Math.floor(this.parameters.volume.dimensions.z * resizeDim3)
    }

    async compute()
    {
        console.time('resize')
        this.tensor = tf.tidy(() =>
        {
            const resized0 = this.tensor
            const resized1 = TensorUtils.resizeLinear(resized0, 2, dimensions.x)
            const resized2 = TensorUtils.resizeLinear(resized1, 1, dimensions.y)
            const resized3 = TensorUtils.resizeLinear(resized2, 0, dimensions.z)
            return resized3
        })
        console.timeEnd('resize')
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