import * as THREE from 'three'
import computeShader from '../../../shaders/includes/computes/smoothing/compute_volume_smoothing.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class Smoothing
{   
    constructor(viewer)
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.renderer = this.viewer.renderer

        console.time('smoothing')
        this.setComputation()
        this.compute()
        this.readComputationData()
        this.writeSmoothingData()
        console.timeEnd('smoothing')

        if (this.viewer.debug.active)
        {
            this.setHelpers()
        }
    }
    
    setComputation()
    { 
        const voxelCountSqrt = Math.ceil(Math.sqrt(this.parameters.volume.count))
        
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2().setScalar(voxelCountSqrt)
        this.computation.instance = new GPUComputationRenderer
        (
            this.computation.dimensions.width, 
            this.computation.dimensions.height, 
            this.renderer.instance
        )        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.setComputationVariable()
    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Float32Array(this.computation.texture.image.data.buffer) 
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms = 
        {
            volume_data:            new THREE.Uniform(this.viewer.textures.volume),
            volume_size:            new THREE.Uniform(this.parameters.volume.size),
            volume_spacing:         new THREE.Uniform(this.parameters.volume.spacing),
            volume_dimensions:      new THREE.Uniform(this.parameters.volume.dimensions),
            computation_dimensions: new THREE.Uniform(this.computation.dimensions),        
        }

        this.computation.instance.init()
    }
    
    compute()
    {
        this.computation.instance.compute()
    }

    readComputationData()
    {
        this.renderer.instance.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.texture.image.data, // computation data are updated also
        )     
        this.computation.texture.needsUpdate = true;
    }

    writeSmoothingData()
    {
        const voxelCount = this.parameters.volume.count;
        const voxelCountSqrt = this.computation.dimensions.width;
        const extra = (voxelCountSqrt * voxelCountSqrt - voxelCount) * 4

        this.data = new Uint8ClampedArray(this.computation.data.slice(0, -extra).map((x) => x * 255))
    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    dispose()
    {
        this.computation.texture.dispose()
        this.computation.instance.dispose()
        this.computation.texture = null
        this.computation = null

        if (this.viewer.debug.active)
        {
            this.helpers.computation.material.dispose()
            this.helpers.computation.geometry.dispose()
            this.viewer.scene.remove(this.helpers.computation)
        }
    }

    setHelpers()
    {
        this.helpers = {}

        this.setComputationHelper()
        this.helpers.computation.visible = true
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
        this.helpers.computation.scale.divideScalar(this.computation.dimensions.height / 2)
        this.viewer.scene.add(this.helpers.computation)
    }

    updateComputationHelper()
    {
        this.helpers.computation.material.map = this.getComputationTexture()
    }
}