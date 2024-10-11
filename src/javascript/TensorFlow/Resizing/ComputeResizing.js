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
        this.capabilities = {}
        this.capabilities.maxTextureSizeWebGL = this.renderer.instance.capabilities.maxTextureSize
        this.capabilities.maxTextureSize = Math.max(...this.parameters.volume.dimensions.toArray())
        this.capabilities.needsResize = this.capabilities.maxTextureSize > this.capabilities.maxTextureSizeWebGL
        this.capabilities.needsResize = true

        if (this.capabilities.needsResize)
        {
            // const dimensionScale = this.capabilities.maxTextureSizeWebGL / this.capabilities.maxTextureSize
            const dimensionScale = 0.5
            this.parameters.volume.dimensions.x = Math.floor(this.parameters.volume.dimensions.x * dimensionScale)
            this.parameters.volume.dimensions.y = Math.floor(this.parameters.volume.dimensions.y * dimensionScale)
            this.parameters.volume.dimensions.z = Math.floor(this.parameters.volume.dimensions.z * dimensionScale)
        }       
    }

    async compute()
    {
        this.tensor = tf.tidy(() =>
        {
            const shape = [this.parameters.volume.dimensions.y, this.parameters.volume.dimensions.x]
            const resizedXY = this.viewer.tensors.volume.resizeBilinear(shape, false, true)
            const resized = this.resizeLinear(resizedXY, 0, this.parameters.volume.dimensions.z)
            return resized
        })

        return { tensor: this.tensor}
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
        this.capabilities.maxTextureSize   = null
        this.capabilities.maxTextureWidth  = null
        this.capabilities.maxTextureHeight = null
        this.capabilities.maxTextureDepth  = null
        this.tensor = null
    }

    // helper tensor functions

    resizeLinear(tensor, axis, newSize)
    {
        const size = tensor.shape[axis]
        const sliceSize = [...tensor.shape]
        sliceSize[axis] = 1

        const startFloor = [0, 0, 0, 0]
        const startCeil  = [0, 0, 0, 0]
        const slices = []

        // Interpolate between the two closest slices along Z for each voxel
        for (let n = 0; n < newSize; n++) 
        {
            const newS   = (n + 0.5) / newSize  // Float index in range (0, 1)
            const s      = newS * size - 0.5    // Float index in range (0, size-1)
            const sFloor = Math.floor(s)        // Lower slice index
            const sCeil  = Math.ceil(s)         // Upper slice index
            const t      = s - sFloor           // Fractional part for interpolation
           
            startFloor[axis] = sFloor
            startCeil[axis] = sCeil
            let sliceFloor = tensor.slice(startFloor, sliceSize)  // Slice at sFloor
            let sliceCeil  = tensor.slice(startCeil,  sliceSize)  // Slice at sCeil
            let slice = this.mix(sliceFloor, sliceCeil, t)        // Slice interpolation

            sliceFloor.dispose()
            sliceCeil.dispose()
            slices.push(slice)
        }

        tensor.dispose()

        const resized = tf.concat(slices, axis)
        tf.dispose(slices)

        return resized
    }

    mix(tensorA, tensorB, t)
    {
        const scaledA = tensorA.mul([1 - t])
        const scaledB = tensorB.mul([t])
        const mixed = scaledA.add(scaledB)
        scaledA.dispose()
        scaledB.dispose()
        return mixed
    }
}