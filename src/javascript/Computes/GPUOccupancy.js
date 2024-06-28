import * as THREE from 'three'
import { GPUComputationRenderer } from 'three/addons/misc/GPUComputationRenderer.js'
import computeShader from '../../shaders/gpgpu/occupancy.glsl'

// assumes intensity data 3D, and data3DTexture
export default class GPUOccupancy
{
    constructor(resolution, texture, renderer)
    {
        this.renderer = renderer

        this.setSizes(texture, resolution)
        this.setTextures(texture)
        this.setGpgpu(renderer)
        this.setBoundingBox()          
    }

    setSizes(texture, resolution)
    {
        this.sizes = {}
        this.sizes.resolution = resolution
        this.sizes.volume = new THREE.Vector3(texture.image.width, texture.image.height, texture.image.depth)
        this.sizes.block = this.sizes.volume.clone().divideScalar(resolution).ceil()
        this.sizes.occupancy = this.sizes.volume.clone().divide(this.sizes.block).ceil()
    }

    setTextures(texture)
    {
        this.textures = {}
        this.textures.volume = texture // assumes intensity data 3D, and data3DTexture

        const data = new Uint8Array(this.sizes.occupancy.x * this.sizes.occupancy.y * this.sizes.occupancy.z * 4).fill(0)
        this.textures.occupancy = new THREE.Data3DTexture(data, this.sizes.occupancy.x, this.sizes.occupancy.y, this.sizes.occupancy.z)
        this.textures.occupancy.format = THREE.RGBAFormat
        this.textures.occupancy.type = THREE.UnsignedByteType // options: UnsignedByteType, FloatType, HalfFloatType, UnsignedShort4444Type, UnsignedShort5551Type, UnsignedInt5999Type
        this.textures.occupancy.wrapS = THREE.ClampToEdgeWrapping
        this.textures.occupancy.wrapT = THREE.ClampToEdgeWrapping
        this.textures.occupancy.wrapR = THREE.ClampToEdgeWrapping
        this.textures.occupancy.minFilter = THREE.NearestFilter
        this.textures.occupancy.magFilter = THREE.NearestFilter
        this.textures.occupancy.unpackAlignment = 1
        this.textures.occupancy.needsUpdate = true    
    }
   
    setGpgpu(renderer)
    {
        this.gpgpu = {}
        this.gpgpu.size = new THREE.Vector2(this.sizes.occupancy.x, this.sizes.occupancy.y * this.sizes.occupancy.z)
        this.gpgpu.computation = new GPUComputationRenderer(this.gpgpu.size.x, this.gpgpu.size.y, renderer)        
        this.gpgpu.computation.setDataType(this.textures.occupancy.type) // options: UnsignedByteType, FloatType, HalfFloatType, UnsignedShort4444Type, UnsignedShort5551Type, UnsignedInt5999Type

        // variable
        this.gpgpu.texture = this.gpgpu.computation.createTexture()
        this.gpgpu.variable = this.gpgpu.computation.addVariable('u_occupancy_data', computeShader, this.gpgpu.texture)
        this.gpgpu.computation.setVariableDependencies(this.gpgpu.variable, [ this.gpgpu.variable ])

        // uniforms
        this.gpgpu.variable.material.uniforms.u_occupancy_size = new THREE.Uniform(this.sizes.occupancy)
        this.gpgpu.variable.material.uniforms.u_volume_size = new THREE.Uniform(this.sizes.volume)
        this.gpgpu.variable.material.uniforms.u_block_size = new THREE.Uniform(this.sizes.block)
        this.gpgpu.variable.material.uniforms.u_volume_data = new THREE.Uniform(this.textures.volume)
        this.gpgpu.variable.material.uniforms.u_threshold = new THREE.Uniform(0)
        this.gpgpu.variable.material.uniforms.u_target = new THREE.Uniform(0)

        // start
        this.gpgpu.computation.init()

        // debug
        this.gpgpu.debug = new THREE.Mesh(
            new THREE.PlaneGeometry(this.gpgpu.size.width, this.gpgpu.size.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: true, opacity: 0.5, visible: false })
        )
        this.gpgpu.debug.material.map = this.gpgpu.computation.getCurrentRenderTarget(this.gpgpu.variable).texture
        this.gpgpu.debug.scale.divideScalar(this.gpgpu.size.height)
    }

    setBoundingBox()
    {
        this.box = new THREE.Box3()
        this.box.min = new THREE.Vector3(0, 0, 0)
        this.box.max = new THREE.Vector3(1, 1, 1)    
    }     

    setThreshold(threshold)
    {
        this.gpgpu.variable.material.uniforms.u_threshold.value = threshold
    }

    readTexture()
    {
        /* CAN CAUSE PERFORMANCE ISSUES */
        this.renderer.readRenderTargetPixels(
            this.gpgpu.computation.getCurrentRenderTarget(this.gpgpu.variable),
            0, 
            0, 
            this.gpgpu.size.width, 
            this.gpgpu.size.height,
            this.textures.occupancy.image.data
        )
        this.textures.occupancy.needsUpdate = true;
    }

    readBoundingBox()
    {
        this.readTexture()
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

    getTexture()
    {
        return this.gpgpu.computation.getCurrentRenderTarget(this.gpgpu.variable).texture
    }

    update()
    {
        this.gpgpu.computation.compute()
        this.gpgpu.debug.material.map = this.getTexture()
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
    }

}