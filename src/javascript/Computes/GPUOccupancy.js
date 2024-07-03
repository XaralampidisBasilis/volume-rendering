import * as THREE from 'three'
import { GPUComputationRenderer } from 'three/addons/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'
import { floatBitsToInt, readIntBits, readIntBytes } from '../Utils/BitwiseUtils.js'
import { reshape1DTo3D } from '../Utils/Reshape.js'

// module-scoped variables
const _color = new THREE.Vector4()
const _position = new THREE.Vector3()

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancy
{
    constructor(resolution, volumeTexture, renderer)
    {
        this.resolution = resolution
        this.volumeTexture = volumeTexture
        this.renderer = renderer

        this.setSizes()
        this.setOccupancy()
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
        this.sizes.block[1] = new THREE.Vector3().copy(this.sizes.block[0]).divideScalar(8).ceil()
        this.sizes.block[2] = new THREE.Vector3().copy(this.sizes.block[1]).divideScalar(64).ceil()

        // multi resolution occupancy map sizes
        this.sizes.map = []
        this.sizes.map[0] = new THREE.Vector3().copy(this.sizes.volume).divide(this.sizes.block[0]).ceil()
        this.sizes.map[1] = new THREE.Vector3().copy(this.sizes.map[0]).multiplyScalar(2 ** 3)
        this.sizes.map[2] = new THREE.Vector3().copy(this.sizes.map[1]).multiplyScalar(2 ** 6)

        this.sizes.computation = new THREE.Vector2(this.sizes.map[0].x, this.sizes.map[0].y * this.sizes.map[0].z)
    }

    setOccupancy()
    {
        this.box = new THREE.Box3()

        // multi resolution occupancy map with 3 levels of detail
        this.map = []
        for(let i = 0; i < 3; i++)
        {   
            const data = new Uint8Array(this.sizes.map[i].x * this.sizes.map[i].y * this.sizes.map[i].z).fill(0)
            this.map[i] = new THREE.Data3DTexture(data, this.sizes.map[i].x, this.sizes.map[i].y, this.sizes.map[i].z)
            this.map[i].format = THREE.RedFormat
            this.map[i].type = THREE.UnsignedByteType 
            this.map[i].wrapS = THREE.ClampToEdgeWrapping
            this.map[i].wrapT = THREE.ClampToEdgeWrapping
            this.map[i].wrapR = THREE.ClampToEdgeWrapping
            this.map[i].minFilter = THREE.NearestFilter
            this.map[i].magFilter = THREE.NearestFilter
            this.map[i].unpackAlignment = 1
            this.map[i].needsUpdate = true            
        }
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
        this.computation.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.sizes.map[0])
        this.computation.variable.material.uniforms.u_threshold = new THREE.Uniform(0)

        // data 3d texture 
        this.computation.dataTexture = new THREE.Data3DTexture(this.computation.texture.image.data, this.sizes.map[0].x, this.sizes.map[0].y, this.sizes.map[0].z)
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
            0, 
            0, 
            this.sizes.computation.width, 
            this.sizes.computation.height,
            this.computation.dataTexture.image.data
        )

        this.computation.dataTexture.needsUpdate = true;
    }

    computeOccupancy()
    {
        this.box.makeEmpty ()

        for (let z = 0; z < this.sizes.map[0]; z++) {
            const offsetZ = this.sizes.map[0].x * this.sizes.map[0].y * z

            for (let y = 0; y < this.sizes.map[0].y; y++) {
                const offsetY = this.sizes.map[0].x * y

                for (let x = 0; x < this.sizes.map[0].x; x++) {

                    let block = x + offsetY + offsetZ
                    let block4 = block * 4  // multiply by 4 because each block has 4 values (R, G, B, A)

                    this.decode( block,
                        this.computation.dataTexture.image.data[block4 + 0],
                        this.computation.dataTexture.image.data[block4 + 1],
                        this.computation.dataTexture.image.data[block4 + 2],
                        this.computation.dataTexture.image.data[block4 + 3],
                    )
                }
            }
        }

        // normalize box volume coordinates
        this.box.min.divide(this.sizes.volume).clampScalar(0, 1)
        this.box.max.divide(this.sizes.volume).clampScalar(0, 1)   
    }

    decode(block, red, green, blue, alpha)
    {
        _color.set(
            floatBitsToInt(red),
            floatBitsToInt(green),
            floatBitsToInt(blue),
            floatBitsToInt(alpha),
        )
        
        // process the unit occupancy block (1 block, 64 bits)
        this.map[0].image.data[block] |= !!_color.x
        this.map[0].image.data[block] |= !!_color.y

        // process the octant occupancy blocks (8 blocks, 8 bits each)
        const block8 = block * 8
        for (let byte = 0; byte < 4; byte++) {
            this.map[1].image.data[block8 + byte + 0] = readIntBytes(_color.x, byte);
            this.map[1].image.data[block8 + byte + 4] = readIntBytes(_color.y, byte);
        }

        // process the hexacontratentant occupancy blocks (64 blocks, 1 bits each)
        const block64 = block * 64
        for (let bit = 0; bit < 32; bit++) {
            this.map[2].image.data[block64 + bit +  0] = readIntBits(_color.x, bit);
            this.map[2].image.data[block64 + bit + 32] = readIntBits(_color.y, bit);
        }

        // expand bounding box with block min
        reshape1DTo3D(this.sizes.volume, _color.z, _position)
        this.box.expandByPoint(_position)

        // expand bounding box with block max
        reshape1DTo3D(this.sizes.volume, _color.w, _position)
        this.box.expandByPoint(_position)
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
        this.computeOccupancy()

        if (this.computation.debug)
            this.computation.debug.material.map = this.computation.texture
    }

    dispose() {

        // Dispose of the volume texture
        if (this.computation.variable.material.uniforms.u_volume_data.value) 
            this.computation.variable.material.uniforms.u_volume_data.value.dispose()
        
    
        // Dispose of the map
        if (this.map) 
            this.map.forEach((map) => {
                if (map) map.dispose()
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