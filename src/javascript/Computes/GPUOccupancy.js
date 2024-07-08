import * as THREE from 'three'
import { GPUComputationRenderer } from 'three/addons/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'
import { floatBitsToInt, readIntBits, readIntBytes } from '../Utils/BitwiseUtils.js'
import ind2sub from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-ind2sub@esm/index.mjs';
import sub2ind from 'https://cdn.jsdelivr.net/gh/stdlib-js/ndarray-sub2ind@esm/index.mjs';

// module scope variables
const _colorData = new THREE.Vector4()
const _boxMin = new THREE.Vector3()
const _boxMax = new THREE.Vector3()
const _occumap0 = new Uint8Array(1)
const _occumap1 = new Uint8Array(8)
const _occumap2 = new Uint8Array(64)

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancy
{
    constructor(resolution, volumeTexture, renderer)
    {
        this.resolution = resolution
        this.volumeTexture = volumeTexture
        this.renderer = renderer

        this.setSizes()
        this.setOccumaps()
        this.setComputation()
    }

    setSizes()
    {
        this.sizes = {}
        this.sizes.resolution = this.resolution
        this.sizes.volume = new THREE.Vector3(this.volumeTexture.image.width, this.volumeTexture.image.height, this.volumeTexture.image.depth)
        
        // multi resolution occupancy map block sizes
        this.sizes.block = []
        this.sizes.block[0] = new THREE.Vector3().copy(this.sizes.volume).divideScalar(this.resolution).ceil()
        this.sizes.block[1] = new THREE.Vector3().copy(this.sizes.block[0]).divideScalar(2).ceil()
        this.sizes.block[2] = new THREE.Vector3().copy(this.sizes.block[1]).divideScalar(4).ceil()

        // multi resolution occupancy map sizes
        this.sizes.occumap = []
        this.sizes.occumap[0] = new THREE.Vector3().copy(this.sizes.volume).divide(this.sizes.block[0]).ceil()
        this.sizes.occumap[1] = new THREE.Vector3().copy(this.sizes.occumap[0]).multiplyScalar(2)
        this.sizes.occumap[2] = new THREE.Vector3().copy(this.sizes.occumap[1]).multiplyScalar(4)

        this.sizes.computation = new THREE.Vector2(this.sizes.occumap[0].x, this.sizes.occumap[0].y * this.sizes.occumap[0].z)
    }

    setOccumaps()
    {
        // multi resolution occupancy map with 3 levels of detail
        this.occumaps = []
        for(let i = 0; i < 3; i++)
        {   
            const data = new Uint8Array(this.sizes.occumap[i].x * this.sizes.occumap[i].y * this.sizes.occumap[i].z).fill(0)
            this.occumaps[i] = new THREE.Data3DTexture(data, ...this.sizes.occumap[i].toArray())
            this.occumaps[i].format = THREE.RedFormat
            this.occumaps[i].type = THREE.UnsignedByteType 
            this.occumaps[i].wrapS = THREE.ClampToEdgeWrapping
            this.occumaps[i].wrapT = THREE.ClampToEdgeWrapping
            this.occumaps[i].wrapR = THREE.ClampToEdgeWrapping
            this.occumaps[i].minFilter = THREE.NearestFilter
            this.occumaps[i].magFilter = THREE.NearestFilter
            this.occumaps[i].unpackAlignment = 1
            this.occumaps[i].needsUpdate = true            
        }

        // set occupancy bounding box box
        this.box = new THREE.Box3()

    }

    setComputation()
    {
        //set computation
        this.computation = {}
        this.computation.instance = new GPUComputationRenderer(this.sizes.computation.width, this.sizes.computation.height, this.renderer)        
        this.computation.instance.setDataType(THREE.FloatType) // options: UnsignedByteType, FloatType, HalfFloatType, UnsignedShort4444Type, UnsignedShort5551Type, UnsignedInt5999Type

        // setup variable
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.variable = this.computation.instance.addVariable('v_compute_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [ this.computation.variable ])

        // variable uniforms
        this.computation.variable.material.uniforms.u_volume_data = new THREE.Uniform(this.volumeTexture)
        this.computation.variable.material.uniforms.u_volume_size = new THREE.Uniform(this.sizes.volume)
        this.computation.variable.material.uniforms.u_block_size = new THREE.Uniform(this.sizes.block)
        this.computation.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.sizes.occumap[0])
        this.computation.variable.material.uniforms.u_threshold = new THREE.Uniform(0)

        // data 3d texture 
        this.computation.dataTexture = new THREE.Data3DTexture(this.computation.texture.image.data, ...this.sizes.occumap[0].toArray())
        this.computation.dataTexture.type = THREE.FloatType // options: UnsignedByteType, FloatType, HalfFloatType, UnsignedShort4444Type, UnsignedShort5551Type, UnsignedInt5999Type
        this.computation.dataTexture.format = THREE.RGBAFormat
        this.computation.dataTexture.minFilter = THREE.NearestFilter
        this.computation.dataTexture.magFilter = THREE.NearestFilter
        this.computation.dataTexture.wrapS = THREE.ClampToEdgeWrapping
        this.computation.dataTexture.wrapT = THREE.ClampToEdgeWrapping
        this.computation.dataTexture.wrapR = THREE.ClampToEdgeWrapping
        this.computation.dataTexture.unpackAlignment = 1
        this.computation.dataTexture.needsUpdate = true    

        // initialize
        this.computation.instance.init()  
    }

    computeDataTexture()
    {
        /* CAN CAUSE PERFORMANCE ISSUES */
        // reads data from GPU to CPU 
        this.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 0, this.sizes.computation.width, this.sizes.computation.height,
            this.computation.dataTexture.image.data
        )

        this.computation.dataTexture.needsUpdate = true;
    }

    computeOccumaps()
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

                    // each compute block has 4 RGBA channels
                    let n = sub2ind(size0, x, y, z)
                    let n4 = n * 4                                          

                    // decode color data  
                    this.decodeColorData(
                        this.computation.dataTexture.image.data[n4 + 0],
                        this.computation.dataTexture.image.data[n4 + 1],
                        this.computation.dataTexture.image.data[n4 + 2],
                        this.computation.dataTexture.image.data[n4 + 3],
                    )  

                    // assign to occumap 0
                    this.occumaps[0].image.data[n] = _occumap0[0]

                    // assign to occumap 1
                    let offset1 = sub2ind(size1, 2 * x, 2 * y, 2 * z)
                    for (const i in indices1)
                        this.occumaps[1].image.data[indices1[i] + offset1] = _occumap1[i]

                    // assign to occumap 2
                    let offset2 = sub2ind(size2, 4 * x, 4 * y, 4 * z)
                    for (const i in indices2)
                        this.occumaps[1].image.data[indices2[i] + offset2] = _occumap2[i]
                  
                    // expand occupancy box
                    this.box.expandByPoint(_boxMin)
                    this.box.expandByPoint(_boxMax)
                }
            }
        }

        // normalize occupancy box
        this.box.min.divide(this.sizes.volume).clampScalar(0, 1)
        this.box.max.divide(this.sizes.volume).clampScalar(0, 1)   
    }

    decodeColorData(red, green, blue, alpha)
    {
        _colorData.set(
            floatBitsToInt(red),
            floatBitsToInt(green),
            floatBitsToInt(blue),
            floatBitsToInt(alpha),
        )

        _occumap0[0] += Boolean(_colorData.x)
        _occumap0[0] += Boolean(_colorData.y)

        for (let byte = 0; byte < 4; byte++) {
            _occumap1[byte + 0] = readIntBytes(_colorData.x, byte)
            _occumap1[byte + 4] = readIntBytes(_colorData.y, byte)
        }

        for (let bit = 0; bit < 32; bit++) {
            _occumap2[bit +  0] = readIntBits(_colorData.x, bit)
            _occumap2[bit + 32] = readIntBits(_colorData.y, bit)
        }

        _boxMin.fromArray(ind2sub(this.sizes.volume.toArray(), _colorData.z))
        _boxMax.fromArray(ind2sub(this.sizes.volume.toArray(), _colorData.w))    
    }

    debug(scene)
    {
        // debug
        this.computation.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.sizes.computation.width, this.sizes.computation.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: true, visible: false })
        )

        this.computation.debug.material.map = this.computation.texture

        // scene
        this.scene = scene
        this.scene.add(this.computation.debug)
        this.computation.debug.scale.divideScalar(this.sizes.computation.height)
    }

    compute(threshold)
    {
        this.computation.variable.material.uniforms.u_threshold.value = threshold
        this.computation.instance.compute()

        this.computation.texture = this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
        this.computeDataTexture()
        this.computeOccumaps()

        if (this.computation.debug)
            this.computation.debug.material.map = this.computation.texture
    }

    dispose() {

        // Dispose of the volume texture
        if (this.computation.variable.material.uniforms.u_volume_data.value) 
            this.computation.variable.material.uniforms.u_volume_data.value.dispose()
        
    
        // Dispose of the map
        if (this.occumaps) 
            this.occumaps.forEach((occumaps) => {
                if (occumaps) occumaps.dispose()
            })
    
        // Dispose of the computation textures
        if (this.computation.texture) 
            this.computation.texture.dispose()
    
    
        if (this.computation.dataTexture) 
            this.computation.dataTexture.dispose()
        
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
        this.computation = null
        this.box = null
        this.map = null
        this.scene = null
        this.renderer = null
        this.resolution = null
        this.volumeTexture = null
    }
    

  
}