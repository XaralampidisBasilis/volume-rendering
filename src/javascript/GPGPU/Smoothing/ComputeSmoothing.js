import * as THREE from 'three'
import computeShader from '../../../shaders/viewers/iso_viewer/chunks/gpgpu/smoothing/gpgpu_smoothing.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class ComputeSmoothing
{   
    constructor(viewer)
    {
        console.time('smoothing')

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

        console.timeEnd('smoothing')
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
            volume_dimensions:      new THREE.Uniform(this.parameters.volume.dimensions),
            volume_inv_dimensions:  new THREE.Uniform(this.parameters.volume.invDimensions),
            computation_dimensions: new THREE.Uniform(this.computation.dimensions),        
        }
        this.computation.variable.material.defines = 
        {
            SMOOTHING_METHOD: this.viewer.material.defines.SMOOTHING_METHOD,
            SMOOTHING_RADIUS: this.viewer.material.defines.SMOOTHING_RADIUS,
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
        const count = this.parameters.volume.count * 4

        // create a data view to manipulate the buffer directly
        let dataView = new DataView(this.computation.data.buffer)
        for (let i4 = 0; i4 < count; i4 += 4)
        {
            dataView.setUint8(i4, Math.min(Math.max(Math.round(this.computation.data[i4] * 255), 0), 255))
        }
        this.data = new Uint8ClampedArray(this.computation.data.buffer).subarray(0, count)
    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }    

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

    updateViewer()
    {
        for (let i = 0; i < this.parameters.volume.count; i++)
        {
            const i4 = i * 4
            this.viewer.textures.volume.image.data[i4 + 0] = this.data[i4 + 0]
        }
        this.data = null;
        this.viewer.textures.volume.needsUpdate = true
    }
}