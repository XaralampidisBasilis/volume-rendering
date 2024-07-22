import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import Occumap from './Helpers/Occumap'
import OccumapHelper from './Helpers/OccumapHelper'
import computeShader from '../../../shaders/includes/computes/occupancy/compute_volume_occupancy_iso.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class Occupancy extends EventEmitter
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.renderer = this.viewer.renderer.instance
        this.scene = this.viewer.scene
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.volumeDivisions = this.viewer.material.uniforms.u_occupancy.value.divisions 

        console.time('occupancy')
        this.setOccubox()
        this.setOccumaps()
        this.setComputation()
        this.compute()
        console.timeEnd('occupancy')

        if (this.viewer.debug.active)
        {
            this.setHelpers()
        }

        this.on('ready', () =>
        {
            this.updateHelpers()
        })
    }

    // setup

    setOccubox()
    {
        this.occubox = new THREE.Box3()
        this.occubox.min.setScalar(0)
        this.occubox.max.setScalar(1)
    }

    setOccumaps()
    {
        const volumeDimensions = this.viewer.parameters.volume.dimensions
        const volumeSubdivisions = 4 * this.volumeDivisions // in order to account for 2 more octree divisions

        // we need to make sure that each occumap fits to the parent perfectly
        this.occumaps = new Array(3).fill().map(() => new Occumap(volumeDimensions, volumeSubdivisions))
        this.occumaps.forEach((occumap, n) => 
        {
            occumap.combineBlocks(2 ** (2 - n))
            occumap.texture.unpackAlignment = 2 ** n
        })
    }

    setComputation()
    { 
        //set computation renderer
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2(this.occumaps[0].dimensions.x, this.occumaps[0].dimensions.y * this.occumaps[0].dimensions.z)
        this.computation.instance = new GPUComputationRenderer(this.computation.dimensions.width, this.computation.dimensions.height, this.renderer)        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.setComputationVariable()
        this.setComputationWorker()

    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer) // shared buffer in order to decode Float32 to Uint32
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms.u_computation = new THREE.Uniform
        ({
            threshold:              this.threshold,
            volume_data:            this.viewer.textures.volume,
            volume_dimensions:      this.viewer.parameters.volume.dimensions,
            block_dimensions:       this.occumaps[0].blockDimensions,
            occupancy_dimensions:   this.occumaps[0].dimensions,
            computation_dimensions: this.computation.dimensions,
        })

        this.computation.instance.init()
    }


    compute()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.computation.variable.material.uniforms.u_computation.value.threshold = this.threshold
        this.computation.instance.compute()
    }

    readComputationData()
    {
        this.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.texture.image.data // due to linked buffers, this.computation.data is updated also
        )     
        this.computation.texture.needsUpdate = true;
    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    // helpers

    setHelpers()
    {
        this.helpers = {}

        this.setOccumapsHelper()
        this.setComputationHelper()
        this.setOccupancyBoxHelper()
        this.helpers.occumaps.visible = false
        this.helpers.computation.visible = false
        this.helpers.occubox.visible = false
    }

    updateHelpers()
    {
        if (this.viewer.debug.active)
        {
            this.updateComputationHelper()
            this.updateOccumapsHelper()
            this.updateOccupancyBoxHelper()
        }
    }

    setOccumapsHelper()
    {
        this.helpers.occumaps = new THREE.Group()

        for (let i = 0; i < 3; i++)
        {
            const helper = new OccumapHelper(this.occumaps[i])

            helper.material.color = new THREE.Color([0x00FFFF, 0x00FF88, 0xFF88AA][i])
            helper.scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size)
            helper.position.copy(this.viewer.parameters.volume.size).divideScalar(-2)
            this.helpers.occumaps.add(helper)
        }

        this.viewer.scene.add(this.helpers.occumaps)
    }

    setComputationHelper()
    {
        this.helpers.computation = new THREE.Mesh
        (
            new THREE.PlaneGeometry(this.computation.dimensions.width, this.computation.dimensions.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, depthTest: false })
        )
        this.helpers.computation.material.map = this.getComputationTexture()
        this.helpers.computation.scale.divideScalar(this.computation.dimensions.height)
        this.viewer.scene.add(this.helpers.computation)
    }

    setOccupancyBoxHelper()
    {
        const center = new THREE.Vector3()
        const size = new THREE.Vector3()
        const box = new THREE.Box3()

        this.occubox.getCenter(center).multiply(this.viewer.parameters.volume.size).sub(this.viewer.parameters.geometry.center)
        this.occubox.getSize(size).multiply(this.viewer.parameters.volume.size)  
        this.helpers.occubox = new THREE.Box3Helper(box.setFromCenterAndSize(center, size), 0xFFFFFF) 
        this.viewer.scene.add(this.helpers.occubox)
    }

    updateOccumapsHelper()
    {
        for (let i = 0; i < 3; i++)
        {
            if (this.helpers.occumaps.children[i].visible) 
                this.helpers.occumaps.children[i].updateOccumap(this.occumaps[i])        
        }
    }

    updateComputationHelper()
    {
        this.helpers.computation.material.map = this.getComputationTexture()
    }

    updateOccupancyBoxHelper()
    {
        const center = new THREE.Vector3()
        const size = new THREE.Vector3()
        this.occubox.getCenter(center).multiply(this.viewer.parameters.volume.size).sub(this.viewer.parameters.geometry.center)
        this.occubox.getSize(size).multiply(this.viewer.parameters.volume.size)  
        this.helpers.occubox.box.setFromCenterAndSize(center, size)
    }

    // dispose

    dispose() 
    {
        if (this.viewer.debug.active)
        {
            this.viewer.scene.remove(this.helpers.occubox)
            this.viewer.scene.remove(this.helpers.occumaps)
            this.viewer.scene.remove(this.helpers.computation)

            this.helpers.occubox.dispose()
            this.helpers.computation.geometry.dispose()
            this.helpers.computation.material.dispose()
            this.helpers.occumaps.children.forEach((helper) => 
            {
                helper.geometry.dispose()
                helper.material.dispose()
            })
            
            this.helpers.occubox = null
            this.helpers.occumap = null
            this.helpers.computation = null
            this.helpers = null
        }

        
        this.occumaps.forEach((occumap) => occumap.dispose())
        this.computation.texture.dispose()
        this.computation.instance.dispose()
        this.computation.worker.terminate()
        this.computation.texture = null
        this.computation.worker = null
        this.computation.data = null
        this.computation = null
        this.occumaps = null
        this.viewer = null
    }
}