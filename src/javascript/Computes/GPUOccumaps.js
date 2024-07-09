import * as THREE from 'three'
import EventEmitter from '../Utils/EventEmitter.js'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'

// assumes intensity data 3D, and data3DTexture
export default class GPUOccumaps extends EventEmitter
{
    constructor(resolution, texture, renderer)
    {
        super()

        this.volume = {}
        this.volume.texture = texture
        this.volume.size = new THREE.Vector3(texture.image.width, texture.image.height, texture.image.depth)
        this.boundingBox = new THREE.Box3()

        this.setOccumaps(resolution)
        this.setComputation(renderer)

        this.on('ready', () => {
            if (this.computation.debug)
                this.computation.debug.material.map = this.getRenderTargetTexture()
        })
    }

    // setup

    setOccumaps(resolution)
    {
        for (let level = 0; level < 3; level++) 
        {   
            const key = `resolution${level}`;
            const step = this.calculateStep(resolution, level);
            const size = this.calculateSize(step, level);
    
            this[key] = 
            {
                step: step,
                size: size,
                texture: this.createTexture(size)
            }
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

        this.setComputationVariable()
        this.setComputationWorker()

    }

    setComputationVariable()
    {
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer)
        this.computation.variable = this.computation.instance.addVariable('v_compute_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])

        this.computation.variable.material.uniforms = {
            u_volume_data: new THREE.Uniform(this.volume.texture),
            u_volume_size: new THREE.Uniform(this.volume.size),
            u_block_size: new THREE.Uniform(this.resolution0.step),
            u_occupancy_size: new THREE.Uniform(this.resolution0.size),
            u_threshold: new THREE.Uniform(0)
        }

        this.computation.instance.init()
    }

    setComputationWorker()
    {
        this.computation.worker = new Worker('./javascript/Workers/WorkerOccumaps.js')
        this.computation.worker.onmessage = this.handleWorkerMessage.bind(this)
    }

    postWorkerMessage() 
    {    
        this.readComputationData()

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

    handleWorkerMessage(event) 
    {
        const result = event.data

        this.resolution0.texture.image.data.set(result.resolution0TextureData)
        this.resolution1.texture.image.data.set(result.resolution1TextureData)
        this.resolution2.texture.image.data.set(result.resolution2TextureData)
        this.boundingBox.min.fromArray(result.boundingBoxMin)
        this.boundingBox.max.fromArray(result.boundingBoxMax)

        // debug
        console.log(
        {
            res0: this.resolution0.texture.image.data,
            res1: this.resolution1.texture.image.data,
            res2: this.resolution2.texture.image.data,
            bbmin: this.boundingBox.min,
            bbmax: this.boundingBox.max
        })

        console.timeEnd('compute')
        this.trigger('ready')
    }

    compute(threshold)
    {
        // update the computation based on threshold
        this.computation.threshold = threshold
        this.computation.variable.material.uniforms.u_threshold.value = threshold

        console.log('')
        console.time('compute')
        this.computation.instance.compute()

        this.postWorkerMessage()
    }

    // helpers

    calculateStep(resolution, level)
    {
        return this.volume.size.clone()
            .divideScalar(resolution)
            .ceil()
            .divideScalar(2 ** level)
            .ceil()
    }

    calculateSize(step, level) 
    {
        return this.volume.size.clone()
            .divide(step)
            .ceil()
            .multiplyScalar(2 ** level);
    }

    createTexture(size) 
    {
        const count = size.x * size.y * size.z;
        const data = new Uint8Array(count).fill(1)
        const texture = new THREE.Data3DTexture(data, ...size.toArray());
        texture.format = THREE.RedFormat;
        texture.type = THREE.UnsignedByteType;
        texture.wrapS = THREE.ClampToEdgeWrapping;
        texture.wrapT = THREE.ClampToEdgeWrapping;
        texture.wrapR = THREE.ClampToEdgeWrapping;
        texture.minFilter = THREE.NearestFilter;
        texture.magFilter = THREE.NearestFilter;
        texture.unpackAlignment = 1;
        texture.needsUpdate = true;
        return texture;
    }

    readComputationData()
    {
            this.computation.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.size.width, 
            this.computation.size.height,
            this.computation.texture.image.data
        )     

        this.computation.texture.needsUpdate = true;
    }

    getRenderTargetTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    // dispose

    dispose() 
    {
        this.disposeVolumeTexture()
        this.disposeOccumaps()
        this.disposeComputationTextures()
        this.disposeComputationWorker()
        this.disposeDebugMesh()
        this.cleanReferences()
    }

    disposeVolumeTexture() 
    {
        if (this.computation.variable.material.uniforms.u_volume_data.value) {
            this.computation.variable.material.uniforms.u_volume_data.value.dispose();
        }
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
        this.boundingBox = null
        this.scene = null
    }

    // debug

    debug(scene)
    {
        // debug
        this.computation.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.computation.size.width, this.computation.size.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: false, visible: false })
        )

        // apply the texture map
        this.computation.debug.material.map = this.getRenderTargetTexture()
        this.computation.debug.scale.divideScalar(this.computation.size.height)

        // add to scene
        this.scene = scene
        this.scene.add(this.computation.debug)
    }

    
}