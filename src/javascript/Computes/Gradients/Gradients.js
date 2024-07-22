import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import computeShader from '../../../shaders/includes/computes/gradients/compute_volume_gradients.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class Gradients extends EventEmitter
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
        this.compute()

        this.readComputationData()
        this.updateVolumeTexture()
        this.dispose()
        
        this.trigger('ready')
    }
    
    setComputation()
    { 
        const width = Math.ceil(Math.sqrt(this.parameters.volume.count))
        
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2().setScalar(width)
        this.computation.instance = new GPUComputationRenderer(this.computation.dimensions.width, this.computation.dimensions.height, this.renderer.instance)        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.setComputationVariable()
    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Float32Array(this.computation.texture.image.data.buffer) // shared buffer 
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
            this.computation.texture.image.data // this.computation.data is updated also, due to linked buffers
        )     
        this.computation.texture.needsUpdate = true;
    }

    updateVolumeTexture()
    {
        this.viewer.textures.volume.dispose()
        this.viewer.textures.volume = new THREE.Data3DTexture
        ( 
            this.computation.data, 
            this.viewer.resource.volume.xLength, 
            this.viewer.resource.volume.yLength,
            this.viewer.resource.volume.zLength 
        ) 
        this.viewer.textures.volume.format = THREE.RGBAFormat
        this.viewer.textures.volume.type = THREE.UnsignedByteType // UnsignedShortType // UnsignedIntType 
        this.viewer.textures.volume.wrapS = THREE.ClampToEdgeWrapping
        this.viewer.textures.volume.wrapT = THREE.ClampToEdgeWrapping
        this.viewer.textures.volume.wrapR = THREE.ClampToEdgeWrapping
        this.viewer.textures.volume.minFilter = THREE.LinearFilter
        this.viewer.textures.volume.magFilter = THREE.LinearFilter
        this.viewer.textures.volume.unpackAlignment = 1
        this.viewer.textures.volume.needsUpdate = true
    }

    dispose()
    {
        this.computation.texture.dispose()
        this.computation.instance.dispose()
        this.computation.texture = null
        this.computation.data = null
        this.computation = null
    }
}