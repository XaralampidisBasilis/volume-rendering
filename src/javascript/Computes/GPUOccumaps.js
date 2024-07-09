import * as THREE from 'three'
import { GPUComputationRenderer } from './GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'
import * as BitUtils from '../Utils/BitUtils.js'
import * as CoordUtils from '../Utils/CoordUtils.js'
import ind2sub from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-ind2sub@esm/index.mjs';
import sub2ind from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-sub2ind@esm/index.mjs';

// module scope variables
const _box_min = new THREE.Vector3()
const _box_max = new THREE.Vector3()
const _occumap_0 = new Uint8Array(1)
const _occumap_1 = new Uint8Array(8)
const _occumap_2 = new Uint8Array(64)

// assumes intensity data 3D, and data3DTexture
export default class GPUOccumaps
{
    constructor(resolution, texture, renderer)
    {
        this.volume = {}
        this.volume.texture = texture
        this.volume.size = new THREE.Vector3(texture.image.width, texture.image.height, texture.image.depth)
        this.boundingBox = new THREE.Box3(
            new THREE.Vector3(0, 0, 0), 
            new THREE.Vector3(1, 1, 1)
        )

        this.setOccumaps(resolution)
        this.setComputation(renderer)
    }

    setOccumaps(resolution)
    {
        // multi resolution occumaps
        for(let i = 0; i < 3; i++)
        {   
            const key = `resolution${i}`
            this[key] = {}

            // parameters
            this[key].step = this.volume.size.clone()
                .divideScalar(resolution)
                .ceil()
                .divideScalar(2 ** i)
                .ceil()

            this[key].size = this.volume.size.clone()
                .divide(this[key].step)
                .ceil()
                .multiplyScalar(2 ** i)

            // texture
            const data = new Uint8Array(this[key].size.x * this[key].size.y * this[key].size.z).fill(1)
            this[key].texture = new THREE.Data3DTexture(data, ...this[key].size.toArray())
            this[key].texture.format = THREE.RedFormat
            this[key].texture.type = THREE.UnsignedByteType 
            this[key].texture.wrapS = THREE.ClampToEdgeWrapping
            this[key].texture.wrapT = THREE.ClampToEdgeWrapping
            this[key].texture.wrapR = THREE.ClampToEdgeWrapping
            this[key].texture.minFilter = THREE.NearestFilter
            this[key].texture.magFilter = THREE.NearestFilter
            this[key].texture.unpackAlignment = 1
            this[key].texture.needsUpdate = true            
        }

    }

    setComputation(renderer)
    { 
        //set computation renderer
        this.computation = {}
        this.computation.renderer = renderer
        this.computation.size = new THREE.Vector2(this.resolution0.size.x, this.resolution0.size.y * this.resolution0.size.z)
        this.computation.instance = new GPUComputationRenderer(this.computation.size.width, this.computation.size.height, this.computation.renderer)        
        this.computation.instance.setDataType(THREE.FloatType) 

        // setup variable
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer) // they share the same buffer. If one changes so does the other
        this.computation.variable = this.computation.instance.addVariable('v_compute_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [ this.computation.variable ])

        // variable uniforms
        this.computation.variable.material.uniforms.u_volume_data = new THREE.Uniform(this.volume.texture)
        this.computation.variable.material.uniforms.u_volume_size = new THREE.Uniform(this.volume.size)
        this.computation.variable.material.uniforms.u_block_size = new THREE.Uniform(this.resolution0.step)
        this.computation.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.resolution0.size)
        this.computation.variable.material.uniforms.u_threshold = new THREE.Uniform(0)      

        // initialize
        this.computation.instance.init()  

        // set computation worker
        this.computation.worker = new Worker('./javascript/Workers/WorkerOccumaps.js')
        this.computation.worker.onmessage = (event) =>
        {
            const result = event.data

            this.resolution0.texture.image.data.set(result.resolution0TextureData)
            this.resolution1.texture.image.data.set(result.resolution1TextureData)
            this.resolution2.texture.image.data.set(result.resolution2TextureData)

            this.boundingBox.min.fromArray(result.boundingBoxMin)
            this.boundingBox.max.fromArray(result.boundingBoxMax)

            console.log('GPUOccumaps worker message: received')
        }
    }

    readData()
    {
        // read data from GPU to CPU 
        this.computation.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.size.width, 
            this.computation.size.height,
            this.computation.texture.image.data
        )     
    }

    readOccumaps() 
    {    
        console.log('GPUOccumaps worker message: posted')
        this.computation.worker.postMessage(
        {
            computationData:        this.computation.data,
            volumeSize:             this.volume.size.toArray(),
            resolution0Size:        this.resolution0.size.toArray(),
            resolution1Size:        this.resolution1.size.toArray(),
            resolution2Size:        this.resolution2.size.toArray(),
            resolution0TextureData: this.resolution0.texture.image.data,
            resolution1TextureData: this.resolution1.texture.image.data,
            resolution2TextureData: this.resolution2.texture.image.data,
        })
    }

    debug(scene)
    {
        // debug
        this.computation.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.computation.size.width, this.computation.size.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: true, visible: false })
        )

        // apply the texture map
        this.computation.debug.material.map = this.getRenderTargetTexture()
        this.computation.debug.scale.divideScalar(this.computation.size.height)

        // add to scene
        this.scene = scene
        this.scene.add(this.computation.debug)
    }

    compute(threshold)
    {
        // update the computation based on threshold
        this.computation.threshold = threshold
        this.computation.variable.material.uniforms.u_threshold.value = threshold
        this.computation.instance.compute()

        // read computation data and update occumap
        this.readData()
        this.readOccumaps()

        // update the debug plane
        if (this.computation.debug)
            this.computation.debug.material.map = this.getRenderTargetTexture()
    }

    getRenderTargetTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    dispose() {

        // Dispose of the volume texture
        if (this.computation.variable.material.uniforms.u_volume_data.value) 
            this.computation.variable.material.uniforms.u_volume_data.value.dispose()
        
        // Dispose of the map
        if (this) 
            this.forEach((occumap) => {
                if (occumap) occumap.dispose()
            })
    
        // Dispose of the computation textures
        if (this.computation.texture) 
            this.computation.texture.dispose()
    
        // Dispose of the GPUComputationRenderer
        if (this.computation.instance) 
            this.computation.instance.dispose()
    
        // Dispose of the debug mesh and its materials and geometries
        if (this.computation.debug) 
        {
            if (this.computation.debug.geometry) 
                this.computation.debug.geometry.dispose()
            
            if (this.computation.debug.material) 
                this.computation.debug.material.dispose()
            
            this.scene.remove(this.computation.debug)
        }
    
        // Clean up references
        this.computation.data = null
        this.computation = null
        this.box = null
        this.map = null
        this.scene = null
    }
    
}