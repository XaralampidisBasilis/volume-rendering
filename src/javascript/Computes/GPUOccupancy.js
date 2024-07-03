import * as THREE from 'three'
import { GPUComputationRenderer } from 'three/addons/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/computes/gpu_occupancy/multi_resolution.glsl'

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancy
{
    constructor(resolution, volumeTexture, renderer)
    {
        this.renderer = renderer

        this.setSizes(volumeTexture, resolution)
        this.setOccupancyMaps()
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

    setOccupancyMaps()
    {
        this.maps = []
    
        for(let i = 0; i < 3; i++)
        {
            const size = this.sizes.occupancy.clone().multiplyScalar(2 ** (3 * i))
            const data = new Uint8Array(size.x * size.y * size.z).fill(0)

            this.maps[i] = new THREE.Data3DTexture(data, size.x, size.y, size.z)
            this.maps[i].format = THREE.RedFormat
            this.maps[i].type = THREE.UnsignedByteType 
            this.maps[i].wrapS = THREE.ClampToEdgeWrapping
            this.maps[i].wrapT = THREE.ClampToEdgeWrapping
            this.maps[i].wrapR = THREE.ClampToEdgeWrapping
            this.maps[i].minFilter = THREE.NearestFilter
            this.maps[i].magFilter = THREE.NearestFilter
            this.maps[i].unpackAlignment = 1
            this.maps[i].needsUpdate = true            
        }
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

    computeOccupancyMaps()
    {

        const occupancy = this.textures.occupancy.image.data
        const numBlocks = this.sizes.occupancy;

        for (let z = 0; z < numBlocks; z++) {
            const offsetZ = numBlocks.x * numBlocks.y * z

            for (let y = 0; y < numBlocks.y; y++) {
                const offsetY = numBlocks.x * y

                for (let x = 0; x < numBlocks.x; x++) {
                    let n = x + offsetY + offsetZ  

                }
            }
        }
    }

    computeBoundingBox()
    {

        this.box = new THREE.Box3()
        this.box.min = new THREE.Vector3(0, 0, 0)
        this.box.max = new THREE.Vector3(1, 1, 1)    

        this.box.min = new THREE.Vector3()
        this.box.max = new THREE.Vector3()

        const blockMin = new THREE.Vector3()
        const blockMax = new THREE.Vector3()
        const occupancy = this.textures.occupancy.image.data
        const numBlocks = this.sizes.occupancy

        for (let z = 0; z < numBlocks.z; z++) {
            const Z = numBlocks.x * numBlocks.y * z

            for (let y = 0; y < numBlocks.y; y++) {
                const Y = numBlocks.x * y

                for (let x = 0; x < numBlocks.x; x++) {
                    let n = (x + Y + Z) * 4                              // multiply by 4 because each voxel has 4 values (R, G, B, A)

                    if (occupancy[n]) { 

                        blockMin.set(x + 0, y + 0, z + 0).multiply(this.sizes.block)
                        blockMax.set(x + 1, y + 1, z + 1).multiply(this.sizes.block)

                        this.box.expandByPoint(blockMin)
                        this.box.expandByPoint(blockMax)
                    }
                }
            }
        }

        // normalize box volume coordinates
        this.box.min.divide(this.sizes.volume).clampScalar(0, 1)
        this.box.max.divide(this.sizes.volume).clampScalar(0, 1)   
        
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