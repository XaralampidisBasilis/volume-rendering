import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import computeShader from '../../../shaders/includes/computes/compute_volume_smoothing.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class Smoothing extends EventEmitter
{   
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.renderer = this.viewer.renderer
        this.resolution = this.viewer.material.uniforms.u_gradient.value.resolution
        this.method = this.viewer.material.uniforms.u_gradient.value.method

        this.setComputation()
        this.setDataTexture()
        this.compute()

        this.readComputationData()
        this.updateVolumeData()
        this.dispose()
    }
    
    setComputation()
    { 
        //set computation renderer
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2
        (
            this.parameters.volume.dimensions.x, 
            this.parameters.volume.dimensions.y * this.parameters.volume.dimensions.z
        )
        this.computation.instance = new GPUComputationRenderer(this.computation.dimensions.width, this.computation.dimensions.height, this.renderer.instance)        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.setComputationVariable()
    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
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

    setDataTexture()
    {
        this.texture = new THREE.Data3DTexture
        ( 
            new Float32Array(this.computation.texture.image.data.buffer), 
            this.parameters.volume.dimensions.x, 
            this.parameters.volume.dimensions.y,
            this.parameters.volume.dimensions.z 
        )

        this.texture.format = THREE.RGBAFormat
        this.texture.type = THREE.FloatType     
        this.texture.wrapS = THREE.ClampToEdgeWrapping
        this.texture.wrapT = THREE.ClampToEdgeWrapping
        this.texture.wrapR = THREE.ClampToEdgeWrapping
        this.texture.minFilter = THREE.LinearFilter
        this.texture.magFilter = THREE.LinearFilter
        this.texture.unpackAlignment = 1
        this.texture.needsUpdate = true
    }
    
    readComputationData()
    {
        this.renderer.instance.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.texture.image.data // due to linked buffers, this.computation.texture.image.data is updated also
        )     
        this.computation.texture.needsUpdate = true;
    }

    updateVolumeData()
    {

    }

    compute()
    {
        this.computation.instance.compute()
    }

    dispose()
    {
        this.texture.dispose()
        this.computation.texture.dispose()
        this.computation.instance.dispose()
        this.computation.texture = null
        this.computation = null
    }
}