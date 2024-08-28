import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import Occumap from './Helpers/Occumap'
import OccumapHelper from './Helpers/OccumapHelper'
import computeShader from '../../../shaders/includes/precomputes/occupancy/compute_volume_occupancy_iso.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'

// assumes intensity data 3D, and data3DTexture
export default class ISOOccupancy extends EventEmitter
{
    constructor(viewer)
    {
        super()

        console.time('occupancy')

        this.viewer = viewer
        this.renderer = this.viewer.renderer.instance
        this.scene = this.viewer.scene
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.volumeDivisions = this.viewer.material.uniforms.u_occupancy.value.divisions 

        this.setOccubox()
        this.setOccumaps()
        this.setComputation()
        this.compute()

        console.timeEnd('occupancy')
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

    setComputationWorker()
    {
        this.computation.worker = new Worker('./javascript/Precomputes/Occupancy/Workers/Worker')
        this.computation.worker.onmessage = this.handleComputationWorker.bind(this)

    }

    handleComputationWorker(event) 
    {
        const output = event.data

        this.occumaps[0].fromArray(output.occumap0)
        this.occumaps[1].fromArray(output.occumap1)
        this.occumaps[2].fromArray(output.occumap2)
        this.occubox.min.fromArray(output.occuboxMin)
        this.occubox.max.fromArray(output.occuboxMax)

        // debug
        // console.log([this.occumaps, this.occubox])

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

        this.computation.worker.postMessage(
        {
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

}