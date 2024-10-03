import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeResizing
{   
    constructor(viewer)
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.tensors = this.viewer.tensors
        this.renderer = this.viewer.renderer
    }

    compute()
    {
        const maxCount = this.renderer.instance.capabilities.maxTextureSize ** 2
        const maxSliceCount = maxCount / this.parameters.dimensions.z
        const aspectRatio = this.parameters.volume.dimensions.x / this.parameters.dimensions.y
        const resizeWidth = Math.floor(Math.sqrt(aspectRatio * maxSliceCount))
        const resizeHeight = Math.floor(Math.sqrt(1 / aspectRatio * maxSliceCount))
        
        this.parameters.volume.dimensions.x = Math.min(this.parameters.volume.dimensions.x, resizeWidth)
        this.parameters.volume.dimensions.y = Math.min(this.parameters.volume.dimensions.y, resizeHeight)

        this.parameters.volume.spacing = new THREE.Vector3().copy(this.parameters.volume.size).divide(this.parameters.volume.dimensions)
        this.parameters.volume.invSpacing = new THREE.Vector3(1, 1, 1).divide(this.parameters.volume.spacing)
        this.parameters.volume.invDimensions = new THREE.Vector3(1, 1, 1).divide(this.parameters.volume.dimensions)
        this.parameters.volume.count = this.parameters.volume.dimensions.reduce((product, value) => product * value, 1)

        this.parameters.volume.tensor.dispose()
        this.parameters.volume.tensor = this.tensors.volume.resizeBilinear([resizeHeight, resizeWidth], false, true)
    }

}