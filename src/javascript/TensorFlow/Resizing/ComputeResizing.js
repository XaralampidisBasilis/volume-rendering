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
        this.parameters.volume.dimensions.z = Math.round(this.parameters.volume.dimensions.z * resizeDim3)
    }

    async compute()
    {
        this.tensor = tf.tidy(() =>
        {
            const volume = this.viewer.tensors.volume
            const resizedX = this.resizeLinear(volume,   2, this.parameters.volume.dimensions.x)
            const resizedY = this.resizeLinear(resizedX, 1, this.parameters.volume.dimensions.y)
            const resizedZ = this.resizeLinear(resizedY, 0, this.parameters.volume.dimensions.z)
            return resizedZ
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
        this.tensor = null
    }

    // helper tensor functions

    resizeLinear(tensor, axis, newSize)
    {
        const size = tensor.shape[axis]
        if (size <= newSize)
             return tensor.clone()     

        // Interpolate between the two closest slices along Z for each voxel
        const slices = []
        for (let n = 0; n < newSize; n++) 
        {
            const newS   = (n + 0.5) / newSize  // Float index in range (0, 1)
            const s      = newS * size - 0.5    // Float index in range (0, size-1)
            const sFloor = Math.floor(s)        // Lower slice index
            const sCeil  = Math.ceil(s)         // Upper slice index
            const t      = s - sFloor           // Fractional part for interpolation
        
            const sliceFloor = this.slice(tensor, axis, sFloor)  // Slice at sFloor
            const sliceCeil  = this.slice(tensor, axis,  sCeil)  // Slice at sCeil
            const slice = this.mix(sliceFloor, sliceCeil, t)     // Slice interpolation
            sliceFloor.dispose()
            sliceCeil.dispose()
            slices.push(slice)
        }

        tensor.dispose()
        const resized = tf.concat(slices, axis)
        tf.dispose(slices)
        return resized       
    }

    slice(tensor, axis, number)
    {
        const begin = tensor.shape.map(() => 0)
        const size = tensor.shape.map((x) => x)
        begin[axis] = number
        size[axis] = 1
        return tensor.slice(begin, size)

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