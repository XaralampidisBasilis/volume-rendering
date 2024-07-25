import * as THREE from 'three'
import computeShader from '../../../shaders/includes/computes/smoothing/compute_volume_smoothing.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'
import { vec2ind } from '../../Utils/CoordUtils'

const _vector = new THREE.Vector3()

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
        this.updateVolumeTexture()
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
        this.computation.dimensions = new THREE.Vector2(voxelCountSqrt, voxelCountSqrt)
        this.computation.instance = new GPUComputationRenderer
        (
            this.computation.dimensions.width, 
            this.computation.dimensions.height, 
            this.renderer.instance
        )        
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
            volume_count:           new THREE.Uniform(this.parameters.volume.count),
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

    updateVolumeTexture()
    {
        // for (let i = 0; i < this.viewer.textures.volume.image.data.length; i++)
        // {
        //     this.viewer.textures.volume.image.data[i] = 255 * this.computation.data[i]
        // }

        for (let z = 0; z < this.parameters.volume.dimensions.z; z++)
        {
            for (let y = 0; y < this.parameters.volume.dimensions.y; y++)
            {
                for (let x = 0; x < this.parameters.volume.dimensions.x; x++)
                {
                    _vector.set(x, y, z)

                    let i = vec2ind(this.parameters.volume.dimensions, _vector)
                    let i4 = i * 4

                    this.viewer.textures.volume.image.data[i4 + 0] = 255 * this.computation.data[i4 + 0]
                    // this.viewer.textures.volume.image.data[i4 + 1] = 255 * this.computation.data[i4 + 1]
                    // this.viewer.textures.volume.image.data[i4 + 2] = 255 * this.computation.data[i4 + 2]
                    // this.viewer.textures.volume.image.data[i4 + 3] = 255 * this.computation.data[i4 + 3]
                }
            }
        }

        this.viewer.textures.volume.needsUpdate = true

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
        this.helpers.computation.scale.divideScalar(this.computation.dimensions.height / 10)
        this.viewer.scene.add(this.helpers.computation)
    }

    updateComputationHelper()
    {
        this.helpers.computation.material.map = this.getComputationTexture()
    }
}