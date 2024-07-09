import * as THREE from 'three'
import { GPUComputationRenderer } from './GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/mono_resolution.glsl'
import  * as BitUtils from '../Utils/BitUtils.js'
import ind2sub from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-ind2sub@esm/index.mjs';
import sub2ind from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-sub2ind@esm/index.mjs';

// module scope variables
const _box_min = new THREE.Vector3()
const _box_max = new THREE.Vector3()
const _occumap_0 = new Uint8Array(1)
const _occumap_1 = new Uint8Array(8)
const _occumap_2 = new Uint8Array(64)

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancy
{
    constructor(resolution, volumeTexture, renderer)
    {
        this.resolution = resolution
        this.renderer = renderer
        this.volumeTexture = volumeTexture
        this.volumeSize = new THREE.Vector3(this.volumeTexture.image.width, this.volumeTexture.image.height, this.volumeTexture.image.depth)

        this.setOccumap()
        this.setComputation()
    }

    setSizes()
    {
        
        // multi resolution occupancy map block sizes
        this.sizes.block = []
        this.sizes.block[0] = new THREE.Vector3().copy(this.volumeSize).divideScalar(this.resolution).ceil()
        this.sizes.block[1] = new THREE.Vector3().copy(this.sizes.block[0]).divideScalar(2).ceil()
        this.sizes.block[2] = new THREE.Vector3().copy(this.sizes.block[1]).divideScalar(4).ceil()

        // multi resolution occupancy map sizes
        this.sizes.occumap = []
        this.sizes.occumap[0] = new THREE.Vector3().copy(this.volumeSize).divide(this.sizes.block[0]).ceil()
        this.sizes.occumap[1] = new THREE.Vector3().copy(this.sizes.occumap[0]).multiplyScalar(2)
        this.sizes.occumap[2] = new THREE.Vector3().copy(this.sizes.occumap[1]).multiplyScalar(4)

    }

    setOccumap()
    {
        this.occumap = {}

        // occumap source volume
        this.occumap.volume = {}
        this.occumap.volume.size = this.volumeSize
        this.occumap.volume.texture = this.volumeTexture
        this.occumap.volume.boundingBox = new THREE.Box3(
            new THREE.Vector3(0, 0, 0), 
            new THREE.Vector3(1, 1, 1)
        )

        // multi resolution occumaps
        for(let i = 0; i < 3; i++)
        {   
            const key = `resolution{i}`

            // sizes
            this.occumap[key].step = this.volumeSize.clone().divideScalar(this.resolution).ceil().divideScalar(2 * i).ceil()
            this.occumap[key].size = this.volumeSize.clone().divide(this.occumap[key].step).ceil().multiplyScalar(2 * i)

            // texture
            const data = new Uint8Array(this.sizes.occumap[i].x * this.sizes.occumap[i].y * this.sizes.occumap[i].z).fill(255)
            this.occumap[key].texture = new THREE.Data3DTexture(data, ...this.sizes.occumap[i].toArray())
            this.occumap[key].texture.format = THREE.RedFormat
            this.occumap[key].texture.type = THREE.UnsignedByteType 
            this.occumap[key].texture.wrapS = THREE.ClampToEdgeWrapping
            this.occumap[key].texture.wrapT = THREE.ClampToEdgeWrapping
            this.occumap[key].texture.wrapR = THREE.ClampToEdgeWrapping
            this.occumap[key].texture.minFilter = THREE.NearestFilter
            this.occumap[key].texture.magFilter = THREE.NearestFilter
            this.occumap[key].texture.unpackAlignment = 1
            this.occumap[key].texture.needsUpdate = true            
        }

    }

    setComputation()
    {
        //set computation
        this.computation = {}
        this.computation.size = new THREE.Vector2(this.occumap.resolution0.size.x, this.occumap.resolution0.size.y * this.occumap.resolution0.size.z)
        this.computation.data = new Uint32Array(this.sizes.computation.width * this.sizes.computation.height)
        this.computation.instance = new GPUComputationRenderer(this.sizes.computation.width, this.sizes.computation.height, this.renderer)        
        this.computation.instance.setDataType(THREE.FloatType) 

        // setup variable
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.variable = this.computation.instance.addVariable('v_compute_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [ this.computation.variable ])

        // variable uniforms
        this.computation.variable.material.uniforms.u_volume_data = new THREE.Uniform(this.volumeTexture)
        this.computation.variable.material.uniforms.u_volume_size = new THREE.Uniform(this.volumeSize)
        this.computation.variable.material.uniforms.u_block_size = new THREE.Uniform(this.occumap.resolution0.block)
        this.computation.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.occumap.resolution0.size)
        this.computation.variable.material.uniforms.u_threshold = new THREE.Uniform(0)      

        // initialize
        this.computation.instance.init()  
    }

    readData()
    {
        // read data from GPU to CPU 
        this.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.sizes.computation.width, 
            this.sizes.computation.height,
            this.computation.texture.image.data
        )     

        // convert float data to uint 
        this.computation.data.set(this.computation.texture.image.data)
        console.log(this.computation.data)
    }

    decodeData(red, green, blue, alpha)
    {
        _occumap_0[0] += Boolean(red)
        _occumap_0[0] += Boolean(green)

        for (let byte = 0; byte < 4; byte++) {
            _occumap_1[byte + 0] = BitUtils.readIntBytes(red, byte)
            _occumap_1[byte + 4] = BitUtils.readIntBytes(green, byte)
        }

        for (let bit = 0; bit < 32; bit++) {
            _occumap_2[bit +  0] = BitUtils.readIntBits(red, bit)
            _occumap_2[bit + 32] = BitUtils.readIntBits(green, bit)
        }

        _box_min.fromArray(ind2sub(this.volumeSize.toArray(), blue))
        _box_max.fromArray(ind2sub(this.volumeSize.toArray(), alpha))    
    }

    readOccumaps()
    {
        this.box.makeEmpty ()

        // convert vec3 to arrays
        const size0 = this.sizes.occumap[0].toArray();
        const size1 = this.sizes.occumap[1].toArray();
        const size2 = this.sizes.occumap[2].toArray();

        // compute first block static linear indices in occumap 1
        const indices1 = []
        for (let z = 0; z < 2; z++) {
            for (let y = 0; y < 2; y++) {
                for (let x = 0; x < 2; x++) {
                    indices1.push(sub2ind(size1, x, y, z))
                }
            }
        }

        // compute first block static linear indices in occumap 2
        const indices2 = []
        for (let z = 0; z < 4; z++) {
            for (let y = 0; y < 4; y++) {
                for (let x = 0; x < 4; x++) {
                    indices2.push(sub2ind(size2, x, y, z))
                }
            }
        }

        // decode the color data of the computed texture
        for (let z = 0; z < this.computation.dataTexture.image.depth; z++) {
            for (let y = 0; y < this.computation.dataTexture.image.height; y++) {
                for (let x = 0; x < this.computation.dataTexture.image.width; x++) {

                    // each data block has 4 RGBA channels
                    let n = sub2ind(size0, x, y, z)
                    let n4 = n * 4                                          

                    // decode color data  
                    this.decodeData(
                        this.computation.data[n4 + 0],
                        this.computation.data[n4 + 1],
                        this.computation.data[n4 + 2],
                        this.computation.data[n4 + 3],
                    )  

                    // assign to occumap 0
                    this.occumap[0].image.data[n] = _occumap_0[0]

                    // assign to occumap 1
                    let offset1 = sub2ind(size1, 2 * x, 2 * y, 2 * z)
                    for (const i in indices1)
                        this.occumap[1].image.data[indices1[i] + offset1] = _occumap_1[i]

                    // assign to occumap 2
                    let offset2 = sub2ind(size2, 4 * x, 4 * y, 4 * z)
                    for (const i in indices2)
                        this.occumap[1].image.data[indices2[i] + offset2] = _occumap_2[i]
                  
                    // expand occupancy box
                    this.box.expandByPoint(_box_min)
                    this.box.expandByPoint(_box_max)
                }
            }
        }

        // normalize occupancy box
        this.box.min.divide(this.volumeSize).clampScalar(0, 1)
        this.box.max.divide(this.volumeSize).clampScalar(0, 1)   
    }

    debug(scene)
    {
        // debug
        this.computation.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.sizes.computation.width, this.sizes.computation.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: true, visible: false })
        )

        // apply the texture map
        this.computation.debug.material.map = this.getRenderTargetTexture()
        this.computation.debug.scale.divideScalar(this.sizes.computation.height)

        // add to scene
        this.scene = scene
        this.scene.add(this.computation.debug)
    }

    compute(threshold)
    {
        // update the computation based on threshold
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
        if (this.occumap) 
            this.occumap.forEach((occumap) => {
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
        this.renderer = null
        this.resolution = null
        this.volumeTexture = null
    }
    

  
}