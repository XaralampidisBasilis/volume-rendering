import * as THREE from 'three'
import computeShader from '../../../shaders/includes/gpgpu/gradients/compute_gradients.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradients
{   
    constructor(viewer)
    {
        console.time('gradients')

        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.renderer = this.viewer.renderer

        this.setComputation()
        this.compute()
        this.readComputation()
        this.compressData()
        this.disposeComputation()

        if (this.viewer.debug.active)
        {
            // this.setHelpers()
        }

        console.timeEnd('gradients')
    }
    
    setComputation()
    { 
        const dataCountSqrt = Math.ceil(Math.sqrt(this.parameters.volume.count))
        
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2(dataCountSqrt, dataCountSqrt)
        this.computation.instance = new GPUComputationRenderer
        (
            this.computation.dimensions.width, 
            this.computation.dimensions.height, 
            this.renderer.instance
        )        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Float32Array(this.computation.texture.image.data.length) 
        this.setComputationVariable()
        
        this.computation.instance.init()
    }

    setComputationVariable()
    {
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms = 
        {
            volume_data:            new THREE.Uniform(this.viewer.textures.source),
            volume_count:           new THREE.Uniform(this.parameters.volume.count),
            volume_sizes:           new THREE.Uniform(this.parameters.volume.size),
            volume_spacing:         new THREE.Uniform(this.parameters.volume.spacing),
            volume_dimensions:      new THREE.Uniform(this.parameters.volume.dimensions),
            computation_dimensions: new THREE.Uniform(this.computation.dimensions),     
            gradient_method:        new THREE.Uniform(this.viewer.material.uniforms.u_gradient.value.method)   
        }
    }
    
    compute()
    {
        this.computation.instance.compute()
    }
    
    readComputation()
    {
        this.renderer.instance.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.data, 
        )     
    }

    compressData()
    {

        this.minLength = Infinity
        this.maxLength = 0
        const dataCount = this.parameters.volume.count * 4

        for (let i4 = 3; i4 < dataCount; i4 += 4) 
        {
            const value = this.computation.data[i4]
            this.minLength = Math.min(this.minLength, value)
            this.maxLength = Math.max(this.maxLength, value)
        }
        this.lengthRange = this.maxLength - this.minLength

        // create a data view to manipulate the buffer directly
        let dataView = new DataView(this.computation.data.buffer)
        
        for (let i4 = 0; i4 < dataCount; i4 += 4)
        {
            dataView.setUint8(i4 + 0, Math.round((this.computation.data[i4 + 0] * 0.5 + 0.5) * 255))
            dataView.setUint8(i4 + 1, Math.round((this.computation.data[i4 + 1] * 0.5 + 0.5) * 255))
            dataView.setUint8(i4 + 2, Math.round((this.computation.data[i4 + 2] * 0.5 + 0.5) * 255))
            dataView.setUint8(i4 + 3, Math.round((this.computation.data[i4 + 3] - this.minLength) / this.lengthRange * 255))
        }
        this.data = new Uint8Array(this.computation.data.buffer).subarray(0, dataCount)
    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }   

    // helpers 
    
    setHelpers()
    {
        this.helpers = {}

        this.setComputationHelper()
        this.helpers.computation.visible = false
    }

    updateHelpers()
    {
        if (this.viewer.debug.active)
        {
            this.updateComputationHelper()
        }
    }

    setComputationHelper()
    {
        this.helpers.computation = new THREE.Mesh
        (
            new THREE.PlaneGeometry(this.computation.dimensions.width, this.computation.dimensions.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, depthTest: false })
        )
        this.helpers.computation.material.map = this.getComputationTexture()
        this.helpers.computation.scale.divideScalar(this.computation.dimensions.height / 10)
        this.viewer.scene.add(this.helpers.computation)
    }

    updateComputationHelper()
    {
        this.helpers.computation.material.map = this.getComputationTexture()
    }

    // dispose

    dispose()
    {
        if (this.viewer.debug.active)
        {
            this.helpers.computation.material.dispose()
            this.helpers.computation.geometry.dispose()
            this.viewer.scene.remove(this.helpers.computation)
        }
    }

    disposeComputation()
    {
        this.computation.texture.dispose()
        this.computation.instance.dispose()
        this.computation.variable = null
        this.computation.texture = null
        this.computation = null
    }
}