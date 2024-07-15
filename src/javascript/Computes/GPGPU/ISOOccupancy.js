import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter.js'
import Occumap from '../../Utils/Occumap.js'
import OccumapHelper from '../../Helpers/OccumapHelper.js'
import computeShader from '../../../shaders/computes/gpu_occupancy/multi_resolution.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer.js'

// assumes intensity data 3D, and data3DTexture
export default class ISOOccupancy extends EventEmitter
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.renderer = this.viewer.renderer.instance
        this.scene = this.viewer.scene
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.volumeDivisions = this.viewer.material.uniforms.u_occupancy.value.resolution 

        this.setOccupancyBox()
        this.setOccumaps()
        this.setComputation()
        this.compute()

        if (this.viewer.debug.active)
        {
            this.setOccumapsHelpers()
        }

        this.on('ready', () =>
        {
            this.updateOccumapsHelpers()
        })
    }

    // setup

    setOccupancyBox()
    {
        this.occupancyBox = new THREE.Box3()
        this.occupancyBox.min.setScalar(0)
        this.occupancyBox.max.setScalar(1)
    }

    setOccumaps()
    {
        const volumeDimensions = this.viewer.parameters.volume.dimensions
        const volumeSubdivisions = 4 * this.volumeDivisions // in order to account for 2 more octree divisions

        // we need to make sure that each occumap fits to the parent perfectly
        this.occumaps = new Array(3).fill().map(() => new Occumap(volumeDimensions, volumeSubdivisions))
        this.occumaps.forEach((occumap, n) => occumap.combineBlocks(2 ** (2 - n)))
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
        
        this.computation.variable.material.uniforms.u_computation = new THREE.Uniform({
            threshold:              this.threshold,
            volume_data:            this.viewer.textures.volume,
            volume_dimensions:      this.viewer.parameters.volume.dimensions,
            block_dimensions:       this.occumaps[0].blockDimensions,
            occupancy_dimensions:   this.occumaps[0].dimensions,
            computation_dimensions: this.computation.dimensions,
        })

        this.computation.instance.init()
    }

    setComputationWorker()
    {
        this.computation.worker = new Worker('./javascript/Computes/Workers/ISOWorker.js')
        this.computation.worker.onmessage = this.handleComputationWorker.bind(this)

    }

    handleComputationWorker(event) 
    {
        const output = event.data

        this.occumaps[0].fromArray(output.occupied0)
        this.occumaps[1].fromArray(output.occupied1)
        this.occumaps[2].fromArray(output.occupied2)
        this.occupancyBox.min.fromArray(output.boxMin)
        this.occupancyBox.max.fromArray(output.boxMax)

        // debug
        // console.log([this.occumaps, this.occupancyBox])

        this.trigger('ready')
    }

    compute()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.computation.variable.material.uniforms.u_computation.value.threshold = this.threshold
        this.computation.instance.compute()
        this.startComputationWorker()
    }

    startComputationWorker() 
    {    
        this.readComputationData()

        this.computation.worker.postMessage({
            computationData:     this.computation.data,
            volumeDimensions:    this.viewer.parameters.volume.dimensions.toArray(),
            occumap0Dimensions:  this.occumaps[0].dimensions.toArray(),
            occumap1Dimensions:  this.occumaps[1].dimensions.toArray(),
            occumap2Dimensions:  this.occumaps[2].dimensions.toArray(),
            occumap0Length:      this.occumaps[0].dimensions.toArray().reduce((a, b) => a * b),
            occumap1Length:      this.occumaps[1].dimensions.toArray().reduce((a, b) => a * b),
            occumap2Length:      this.occumaps[2].dimensions.toArray().reduce((a, b) => a * b),
        })
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

    // debug

    setOccumapsHelpers()
    {
        const colors = [0x00FFFF, 0x00FF88, 0xFF88AA]
        const opacity = [0.2, 0.3, 0.2]

        this.helpers = {}
        this.helpers.occumaps = this.occumaps.map((occumap) => new OccumapHelper(occumap))

        this.helpers.occumaps.forEach((occumapHelper, i) => 
        {
            occumapHelper.visible = false
            occumapHelper.material.color = new THREE.Color(colors[i])
            occumapHelper.material.opacity = opacity[i]

            occumapHelper.scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size)
            occumapHelper.position.copy(this.viewer.parameters.volume.size).divideScalar(-2)

        })

        this.helpers.occumaps.forEach((occumapHelper) => this.viewer.scene.add(occumapHelper))
    }

    updateOccumapsHelpers()
    {
        if (this.viewer.debug.active)
        {
            for (let i = 0; i < 3; i++)
            {
                if (this.helpers.occumaps[i].visible) 
                    this.helpers.occumaps[i].updateOccumap(this.occumaps[i])        
            }
        }
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