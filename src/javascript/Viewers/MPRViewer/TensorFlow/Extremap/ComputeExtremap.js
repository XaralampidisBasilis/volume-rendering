import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from '../../../../Utils/TensorUtils'

// assumes intensity data 3D, and data3DTexture
export default class ComputeExtremap
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        
        this.setParameters()
        this.setTexture()
    }

    setParameters()
    {
        this.parameters = this.viewer.parameters
        const divisions = this.viewer.material.uniforms.u_extremap.value.divisions
        const dimensions = this.parameters.volume.dimensions.clone().divideScalar(divisions).ceil()

        // set parameters
        this.parameters.extremap = {}
        this.parameters.extremap.dimensions = new THREE.Vector3().copy(dimensions)
        this.parameters.extremap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(divisions)
        this.parameters.extremap.size = new THREE.Vector3().copy(this.parameters.volume.spacing).multiply(this.parameters.extremap.dimensions)
        this.parameters.extremap.invDimensions =  new THREE.Vector3().setScalar(1).divide(this.parameters.extremap.dimensions)
        this.parameters.extremap.invSpacing = new THREE.Vector3().setScalar(1).divide(this.parameters.extremap.spacing)
        this.parameters.extremap.invSize = new THREE.Vector3().setScalar(1).divide(this.parameters.extremap.size)
        this.parameters.extremap.blocks = dimensions.toArray().reduce((blocks, dim) => blocks * dim, 1)
        this.parameters.extremap.length = this.parameters.extremap.blocks * 2
        this.parameters.extremap.divisions = divisions
 
    }

    setTexture()
    {
        const data = new Uint8ClampedArray(this.parameters.extremap.length)
        const dimensions = this.parameters.extremap.dimensions.toArray()

        // set texture
        this.viewer.textures.extremap = new THREE.Data3DTexture(data, ...dimensions)     
        this.viewer.textures.extremap.type = THREE.UnsignedByteType
        this.viewer.textures.extremap.format = THREE.RGFormat
        this.viewer.textures.extremap.wrapS = THREE.ClampToEdgeWrapping
        this.viewer.textures.extremap.wrapT = THREE.ClampToEdgeWrapping
        this.viewer.textures.extremap.wrapR = THREE.ClampToEdgeWrapping
        this.viewer.textures.extremap.minFilter = THREE.LinearFilter
        this.viewer.textures.extremap.magFilter = THREE.LinearFilter
        this.viewer.textures.extremap.needsUpdate = true
    }

    async compute()
    {   
        console.time('computeExtremap')
        tf.tidy(() => 
        {
            const divisions = new Array(3).fill(this.parameters.extremap.divisions)
            const volume = this.viewer.tensors.volume

            // compute the minima and maxima occupancy  
            const minima = this.minPool3d(volume, divisions, divisions, 'same')
            const maxima = tf.maxPool3d(volume, divisions, divisions, 'same')
            
            // convert values to uint8 
            this.minimap = this.quantize(minima)
            this.maximap = this.quantize(maxima)
        })

        this.updateTexture()
        this.updateUniforms()
        console.timeEnd('computeExtremap')
    }

    updateTexture()
    {
        for (let i = 0; i < this.parameters.extremap.length; i++) 
        {
            const i2 = i * 2
            this.viewer.textures.extremap.image.data[i2 + 0] = this.minimap[i]
            this.viewer.textures.extremap.image.data[i2 + 1] = this.maximap[i]
        }
        
        this.viewer.textures.extremap.needsUpdate = true
    }

    updateUniforms()
    {
        this.viewer.material.uniforms.u_extremap.value.dimensions.copy(this.parameters.extremap.dimensions)
        this.viewer.material.uniforms.u_extremap.value.spacing.copy(this.parameters.extremap.spacing)
        this.viewer.material.uniforms.u_extremap.value.size.copy(this.parameters.extremap.size)
        this.viewer.material.uniforms.u_extremap.value.inv_dimensions.copy(this.parameters.extremap.invDimensions)
        this.viewer.material.uniforms.u_extremap.value.inv_spacing.copy(this.parameters.extremap.invSpacing)
        this.viewer.material.uniforms.u_extremap.value.inv_size.copy(this.parameters.extremap.invSpacing)
        this.viewer.material.uniforms.u_textures.value.extremap = this.viewer.textures.extremap
        this.viewer.material.needsUpdate = true
    }

    restart()
    {
        this.viewer.parameters.extremap = {}
        this.viewer.textures.extremap.dispose()

        this.setParameters()
        this.setTexture()
    }

    destroy() 
    {
        this.data = null;
        this.minimap = null;
        this.maximap = null;
        this.viewer = null;
        this.parameters = null;
        console.log('ComputeOccupancy destroyed and resources freed.');
    }

    minPool3d(tensor, filterSize, strides, pad,)
    {
        const tensorNegative = tensor.mul([-1])
        const tensorNegativeMaxPool = tf.maxPool3d(tensorNegative, filterSize, strides, pad)
        tensorNegative.dispose()
        const tensorMinPool = tensorNegativeMaxPool.mul([-1])
        tensorNegativeMaxPool.dispose()
        return tensorMinPool
    } 

    quantize(tensor)
    {
        const tensor255 = tensor.mul([255])
        tensor.dispose()
        const arrayUint8 = new Uint8Array(tensor255.dataSync())
        tensor255.dispose()
        return arrayUint8
    }
}