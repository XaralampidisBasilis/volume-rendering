import * as THREE from 'three'
import { GPUComputationRenderer } from 'three/addons/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/octree.glsl'
import { floatBitsToInt, readIntBits, readIntBytes } from '../Utils/BitwiseUtils.js'
import { reshape1DTo3D } from '../Utils/Reshape.js'

// module-scoped variables
const _vector4 = new THREE.Vector4()
const _vector3 = new THREE.Vector3()
const _vector2 = new THREE.Vector2()

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancyOctree
{
    constructor(resolution, volumeTexture, renderer)
    {
        this.renderer = renderer

        this.setSizes(volumeTexture, resolution)
        this.setOctree()
        this.setComputation(volumeTexture, renderer)
    }

    setSizes(volumeTexture, resolution)
    {
        this.sizes = {}
        this.sizes.resolution = resolution
        this.sizes.volume = new THREE.Vector3(volumeTexture.image.width, volumeTexture.image.height, volumeTexture.image.depth)
        this.sizes.block = new THREE.Vector3().copy(this.sizes.volume).divideScalar(resolution).ceil()
        this.sizes.occupancy = new THREE.Vector3().copy(this.sizes.volume).divide(this.sizes.block).ceil()
        this.sizes.computation = new THREE.Vector2(this.sizes.occupancy.x, this.sizes.occupancy.y * this.sizes.occupancy.z)
    }

    setOctree()
    {
        this.octree = {}
        this.octree.box = THREE.Box3()

        // octree has 3 level of detail (lod)
        this.octree.maps = []

        for(let i = 0; i < 3; i++)
        {   
            const size = this.sizes.occupancy.clone().multiplyScalar(2 ** (3 * i))
            const data = new Uint8Array(size.x * size.y * size.z).fill(0)

            this.octree.maps[i] = new THREE.Data3DTexture(data, size.x, size.y, size.z)
            this.octree.maps[i].format = THREE.RedFormat
            this.octree.maps[i].type = THREE.UnsignedByteType 
            this.octree.maps[i].wrapS = THREE.ClampToEdgeWrapping
            this.octree.maps[i].wrapT = THREE.ClampToEdgeWrapping
            this.octree.maps[i].wrapR = THREE.ClampToEdgeWrapping
            this.octree.maps[i].minFilter = THREE.NearestFilter
            this.octree.maps[i].magFilter = THREE.NearestFilter
            this.octree.maps[i].unpackAlignment = 1
            this.octree.maps[i].needsUpdate = true            
    o   }
    }

    setComputation(volumeTexture, renderer)
    {
        //set computation
        this.computation = {}
        this.computation.instance = new GPUComputationRenderer(this.sizes.computation.width, this.sizes.computation.height, renderer)        
        this.computation.instance.setDataType(THREE.FloatType) // options: UnsignedByteType, FloatType, HalfFloatType, UnsignedShort4444Type, UnsignedShort5551Type, UnsignedInt5999Type

        // setup variable
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.variable = this.computation.instance.addVariable('v_compute_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [ this.computation.variable ])

        // variable uniforms
        this.computation.variable.material.uniforms.u_volume_data = new THREE.Uniform(volumeTexture)
        this.computation.variable.material.uniforms.u_volume_size = new THREE.Uniform(this.sizes.volume)
        this.computation.variable.material.uniforms.u_block_size = new THREE.Uniform(this.sizes.block)
        this.computation.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.sizes.occupancy)
        this.computation.variable.material.uniforms.u_threshold = new THREE.Uniform(0)

        // data 3d texture 
        this.computation.dataTexture = new THREE.Data3DTexture(this.computation.texture.image.data, this.sizes.occupancy.x, this.sizes.occupancy.y, this.sizes.occupancy.z)
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

    setThreshold(threshold)
    {
        this.computation.variable.material.uniforms.u_threshold.value = threshold
    }
    
    debugComputation(scene)
    {
        // debug
        this.computation.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.sizes.computation.width, this.sizes.computation.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: true, visible: false })
        )

        this.computation.debug.material.map = this.getTexture()

        // scene
        this.scene = scene
        this.scene.add(this.computation.debug)
        this.computation.debug.scale.divideScalar(this.sizes.computation.height)
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

    decodeDataTexture(block, red, green, blue, alpha)
    {
        _vector4.x = floatBitsToInt(red)
        _vector4.y = floatBitsToInt(green)
        _vector4.z = floatBitsToInt(blue)
        _vector4.w = floatBitsToInt(alpha)

        // process the unit occupancy block (1 block, 64 bits)
        this.octree.maps[0].image.data[block] |= !!_vector4.x
        this.octree.maps[0].image.data[block] |= !!_vector4.y

        // process the octant occupancy blocks (8 blocks, 8 bits each)
        const block8 = block * 8
        for (let byte = 0; byte < 4; byte++) {
            this.octree.maps[1].image.data[block8 + byte + 0] = readIntBytes(_vector4.x, byte);
            this.octree.maps[1].image.data[block8 + byte + 4] = readIntBytes(_vector4.y, byte);
        }

        // process the hexacontratentant occupancy blocks (64 blocks, 1 bits each)
        const block64 = block * 64
        for (let bit = 0; bit < 32; bit++) {
            this.octree.maps[2].image.data[block64 + bit +  0] = readIntBits(_vector4.x, bit);
            this.octree.maps[2].image.data[block64 + bit + 32] = readIntBits(_vector4.y, bit);
        }

        // expand octree bounding box with block min
        reshape1DTo3D(this.sizes.volume, _vector4.z, _vector3)
        this.octree.box.expandByPoint(_vector3)

        // expand octree bounding box with block max
        reshape1DTo3D(this.sizes.volume, _vector4.w, _vector3)
        this.octree.box.expandByPoint(_vector3)
    }

    computeOctree()
    {
        this.octree.box.makeEmpty ()

        for (let z = 0; z < this.sizes.occupancy; z++) {
            const offsetZ = this.sizes.occupancy.x * this.sizes.occupancy.y * z

            for (let y = 0; y < this.sizes.occupancy.y; y++) {
                const offsetY = this.sizes.occupancy.x * y

                for (let x = 0; x < this.sizes.occupancy.x; x++) {

                    let block = x + offsetY + offsetZ
                    let block4 = block * 4  // multiply by 4 because each block has 4 values (R, G, B, A)

                    this.decodeDataTexture( block,
                        this.computation.dataTexture.image.data[block4 + 0],
                        this.computation.dataTexture.image.data[block4 + 1],
                        this.computation.dataTexture.image.data[block4 + 2],
                        this.computation.dataTexture.image.data[block4 + 3],
                    )
                }
            }
        }

        // normalize box volume coordinates
        this.octree.box.min.divide(this.sizes.volume).clampScalar(0, 1)
        this.octree.box.max.divide(this.sizes.volume).clampScalar(0, 1)   
    }

    update()
    {
        this.computation.instance.compute()
        this.computation.texture = this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
        this.computeDataTexture()
        this.computeBoundingBox()

        if (this.computation.debug)
            this.computation.debug.material.map = this.computation.texture
    }

    dispose()
    {
        // Dispose textures
        this.textures.volume.dispose();
        this.textures.occupancy.dispose();

        // Dispose GPGPU computation renderer
        this.gpgpu.computation.dispose();

        // Dispose debug mesh and its materials and geometries
        this.gpgpu.debug.geometry.dispose();
        this.gpgpu.debug.material.dispose();

        // remove debug plane
        if (this.gpgpu.debug)
            this.scene.remove(this.gpgpu.debug)
    }

  
}