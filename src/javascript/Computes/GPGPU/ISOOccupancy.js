import * as THREE from 'three'
import EventEmitter from '../Utils/EventEmitter.js'
import Occumap from './Occumap.js'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'

// assumes intensity data 3D, and data3DTexture
export default class ISOOccupancy extends EventEmitter
{
    constructor(viewer, volumeDivisions)
    {
        super()

        this.viewer = viewer
        this.renderer = this.viewer.renderer
        this.scene = this.viewer.scene
        this.debug = this.viewer.debug
        this.threshold = this.viewer.material.uniforms.u_raycasting.value.threshold
        this.volumeDivisions = volumeDivisions 

        this.setOccupancyBox()
        this.setOccupancyMaps()
        this.setComputation()
    }

    // setup

    setOccupancyBox()
    {
        this.occupancyBox = new THREE.Box3()
        this.occupancyBox.min.setScalar(0)
        this.occupancyBox.max.setScalar(1)
    }

    setOccupancyMaps()
    {
        const volumeDimensions = this.viewer.parameters.volume.dimensions
        const volumeSubdivisions = 4 * this.volumeDivisions // in order to account for 2 more octree divisions

        this.occupancyMaps = []

        for (let n = 2; n >= 0; n++) 
            this.occupancyMaps.push( new Occumap(volumeDimensions, volumeSubdivisions).combineBlocks(2 ** n) )
    }

    setComputation()
    { 
        //set computation renderer
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2(this.occupancyMaps[0].dimensions.x, this.occupancyMaps[0].dimensions.y * this.occupancyMaps[0].dimensions.z)
        this.computation.instance = new GPUComputationRenderer(this.computation.dimensions.width, this.computation.dimensions.height, this.renderer)        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.setComputationVariable()
        this.setComputationWorker()

    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer)
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms.u_computation = new THREE.Uniform({
            threshold:              this.threshold,
            volume_data:            this.viewer.textures.volume,
            volume_dimensions:      this.viewer.parameters.volume.dimensions,
            block_dimensions:       this.occupancyMaps[0].blockDimensions,
            occupancy_dimensions:   this.occupancyMaps[0].dimensions,
            computation_dimensions: this.computation.dimensions,
        })

        this.computation.instance.init()
    }

    readComputationData()
    {
        this.renderer.readRenderTargetPixels(
        this.computation.instance.getCurrentRenderTarget(this.computation.variable),
        0, 
        0, 
        this.computation.size.width, 
        this.computation.size.height,
        this.computation.texture.image.data // due to linked buffers, this.computation.data is updated also
        )     

        this.computation.texture.needsUpdate = true;
    }

    setComputationWorker()
    {
        this.computation.worker = new Worker('./javascript/Computes/Workers/ISOOccupancyWorker.js')
        this.computation.worker.onmessage = this.handleComputationWorker.bind(this)
    }

    startComputationWorker() 
    {    
        this.readComputationData()

        this.computation.worker.postMessage({
            computationData:        this.computation.data,
            volumeSize:             this.viewer.parameters.volume.dimensions.toArray(),
            resolution0Size:        this.occupancyMaps[0].dimensions.toArray(),
            resolution1Size:        this.occupancyMaps[1].dimensions.toArray(),
            resolution2Size:        this.occupancyMaps[2].dimensions.toArray(),
            resolution0TextureData: this.occupancyMaps[0].toArray(),
            resolution1TextureData: this.occupancyMaps[1].toArray(),
            resolution2TextureData: this.occupancyMaps[2].toArray(),
        })
    }

    handleComputationWorker(event) 
    {
        const result = event.data

        this.occupancyMaps[0].fromArray(result.resolution0TextureData)
        this.occupancyMaps[1].fromArray(result.resolution1TextureData)
        this.occupancyMaps[2].fromArray(result.resolution2TextureData)
        this.occupancyBox.min.fromArray(result.boundingBoxMin)
        this.occupancyBox.max.fromArray(result.boundingBoxMax)

        // console.log(
        // {
        //     res0: this.resolution0.texture.image.data,
        //     res1: this.resolution1.texture.image.data,
        //     res2: this.resolution2.texture.image.data,
        //     bbmin: this.boundingBox.min,
        //     bbmax: this.boundingBox.max
        // })

        this.trigger('ready')
    }

    compute()
    {
        this.threshold = this.viewer.material.uniforms.u_raycasting.value.threshold
        this.computation.variable.material.uniforms.u_computation.value.threshold = this.threshold
        this.computation.instance.compute()
        this.startComputationWorker()
    }

    // helpers

    getRenderTargetTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    // dispose

    dispose() 
    {
        this.disposeOccumaps()
        this.disposeComputationTextures()
        this.disposeComputationWorker()
        this.disposeDebugMesh()
        this.cleanReferences()
    }

    disposeOccumaps() 
    {
        ['resolution0', 'resolution1', 'resolution2'].forEach(key => {
            if (this[key].texture) this[key].texture.dispose();
        })
    }

    disposeComputationTextures() 
    {
        if (this.computation.texture) this.computation.texture.dispose()
        if (this.computation.instance) this.computation.instance.dispose()
    }

    disposeComputationWorker()
    {
        if (this.computation.worker) {
            this.computation.worker.terminate();
            this.computation.worker = null;
        }
    }

    disposeDebugMesh() 
    {
        if (this.computation.debug) {
            if (this.computation.debug.geometry) this.computation.debug.geometry.dispose()
            if (this.computation.debug.material) this.computation.debug.material.dispose()
            if (this.scene) this.scene.remove(this.computation.debug)
        }
    }

    cleanReferences() 
    {
        this.computation.data = null
        this.computation = null
        this.occupancyBox = null
        this.scene = null
    }
}