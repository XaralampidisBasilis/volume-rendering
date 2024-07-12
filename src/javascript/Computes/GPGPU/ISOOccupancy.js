import * as THREE from 'three'
import * as CoordUtils from '../../Utils/CoordUtils.js'
import EventEmitter from '../../Utils/EventEmitter.js'
import Occumap from '../../Utils/Occumap.js'
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
        this.setOccupancyMaps()
        this.setComputation()
        this.compute()

        if (this.viewer.debug.active)
        {
            this.setOccumapsHelpers()
        }

        this.on('ready', () => // event when worker finished computation
        {
            this.updateOccupancyUniforms()

            if (this.viewer.debug.active)
            {
                this.updateOccumapsHelpers()
            }
        })
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

        // we need to make sure that each occumap fits to the parent perfectly
        this.occupancyMaps = new Array(3).fill().map(() => new Occumap(volumeDimensions, volumeSubdivisions))
        this.occupancyMaps.forEach((occumap, n) => occumap.combineBlocks(2 ** (2 - n)))
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
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer) // shared buffer in order to decode Float32 to Uint32
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

    setComputationWorker()
    {
        this.computation.worker = new Worker('./javascript/Computes/Workers/ISOWorker.js')
        this.computation.worker.onmessage = this.handleComputationWorker.bind(this)
    }

    startComputationWorker() 
    {    
        this.readComputationData()

        this.computation.worker.postMessage({
            computationData:     this.computation.data,
            volumeDimensions:    this.viewer.parameters.volume.dimensions.toArray(),
            occumap0Dimensions:  this.occupancyMaps[0].dimensions.toArray(),
            occumap1Dimensions:  this.occupancyMaps[1].dimensions.toArray(),
            occumap2Dimensions:  this.occupancyMaps[2].dimensions.toArray(),
            occumap0Length:      this.occupancyMaps[0].dimensions.toArray().reduce((a, b) => a * b),
            occumap1Length:      this.occupancyMaps[1].dimensions.toArray().reduce((a, b) => a * b),
            occumap2Length:      this.occupancyMaps[2].dimensions.toArray().reduce((a, b) => a * b),
        })
    }

    handleComputationWorker(event) 
    {
        const output = event.data

        this.occupancyMaps[0].fromArray(output.occupied0)
        this.occupancyMaps[1].fromArray(output.occupied1)
        this.occupancyMaps[2].fromArray(output.occupied2)
        this.occupancyBox.min.fromArray(output.boxMin)
        this.occupancyBox.max.fromArray(output.boxMax)

        console.log([this.occupancyMaps, this.occupancyBox])

        this.trigger('ready')
    }

    updateOccupancyUniforms()
    {
        this.viewer.material.uniforms.u_sampler.value.occupancy = this.getComputationTexture()
        this.viewer.material.uniforms.u_occupancy.value.size = this.occupancyMaps[0].dimensions
        this.viewer.material.uniforms.u_occupancy.value.block = this.occupancyMaps[0].blockDimensions
        this.viewer.material.uniforms.u_occupancy.value.box_min = this.occupancyBox.min
        this.viewer.material.uniforms.u_occupancy.value.box_max = this.occupancyBox.max
    }

    compute()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.computation.variable.material.uniforms.u_computation.value.threshold = this.threshold
        this.computation.instance.compute()
        this.startComputationWorker()
    }

    // debug

    debugComputation()
    {

    }

    setOccumapsHelpers()
    {

        const helperColors = [0x00FFFF, 0x00FF88, 0x8888FF]


        this.helpers = {}
        this.helpers.occupancyMaps = new Array(3).fill().map(() => new THREE.Group())
        this.helpers.occupancyMaps.forEach((group, i) => 
        {
            group.scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size)
            group.position.copy(this.viewer.parameters.volume.size).divideScalar(2).negate()
            group.visible = false
            
            for (let n = 0; n < this.occupancyMaps[i].data.length; n++)
            {
                const box = this.occupancyMaps[i].getBlockBox(n)
                box.expandByScalar(-0.01)

                const helper = new THREE.Box3Helper(box)
                helper.material.color = new THREE.Color(helperColors[i])
                helper.material.visible = true
                helper.material.depthWrite = false
                helper.material.transparent = true
                helper.material.opacity = 0.2 * (i + 0.5)

                group.add(helper)     
            }
        })

        this.viewer.scene.add(...this.helpers.occupancyMaps)
    }

    updateOccumapsHelpers()
    {
        this.helpers.occupancyMaps.forEach((group, i) => 
        {
            group.children.forEach((helper, n) => 
            {
                helper.material.visible = Boolean(this.occupancyMaps[i].data[n])
            })
        })

        // this.viewer.mesh.visible = false
        this.helpers.occupancyMaps[0].visible = true
        this.helpers.occupancyMaps[1].visible = true
        this.helpers.occupancyMaps[2].visible = true
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