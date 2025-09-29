import * as THREE from 'three'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Configs from '../../Utils/Configs'
import IsosurfaceShaderMaterial from './IsosurfaceShaderMaterial'

export default class ISOViewer extends EventEmitter
{
    static instance = null

    constructor()
    {
        super()
   
        if (ISOViewer.instance) 
        {
            return ISOViewer.instance
        }
        ISOViewer.instance = this

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.computes = this.experience.computes
        this.debug = this.experience.debug
        this.configs = this.experience.configs
        
        this.setMesh()
    }

    setMesh()
    {   
        this.material = IsosurfaceShaderMaterial()
        this.geometry = new THREE.BoxGeometry(1, 1, 1)
        this.mesh = new THREE.Mesh(this.geometry, this.material)
    }

    start()
    {
        this.startTextureUniforms()
        this.startVolumeUniforms()
        this.startMethodsDefines()
        this.startIteratorDefines()

        this.size = this.computes.volumeMap.size
        this.mesh.scale.copy(this.size)
    }

    startTextureUniforms()
    {
        const computes = this.computes
        const uniforms = this.material.uniforms

        uniforms.u_textures.value.interpolation_map = computes.interpolationMap.getTexture()
        uniforms.u_textures.value.occupancy_map = computes.occupancyMap.getTexture()
        uniforms.u_textures.value.distance_map = computes.distanceMap?.getTexture()

        computes.interpolationMap.tensor.dispose()
        computes.occupancyMap.tensor.dispose()
        computes.distanceMap?.tensor.dispose()
    }

    startVolumeUniforms()
    {
        const computes = this.computes
        const uniforms = this.material.uniforms

        const scale = new THREE.Matrix4().makeScale(...computes.volumeMap.dimensions)
        const translate = new THREE.Matrix4().makeTranslation(0.5, 0.5, 0.5)

        uniforms.u_volume.value.grid_matrix.multiplyMatrices(scale, translate)
        uniforms.u_volume.value.dimensions.copy(computes.volumeMap.dimensions)
        uniforms.u_volume.value.spacing.copy(computes.volumeMap.spacing)
        uniforms.u_volume.value.size.copy(computes.volumeMap.size)
        uniforms.u_volume.value.blocks.copy(computes.occupancyMap.dimensions)
        uniforms.u_volume.value.inv_dimensions.fromArray(uniforms.u_volume.value.dimensions.toArray().map(x => 1/x))
        uniforms.u_volume.value.anisotropy.copy(uniforms.u_volume.value.spacing).normalize()
        uniforms.u_volume.value.stride = this.configs.blockSize
    }

    startMethodsDefines()
    {
        const configs = this.configs
        const defines = this.material.defines

        defines.MARCHING_METHOD = Configs.MarchingMethods.findIndex((x) => x === configs.marchingMethod) + 1
        defines.INTERPOLATION_METHOD = Configs.InterpolationMethods.findIndex((x) => x === configs.interpolationMethod) + 1
        defines.SKIPPING_METHOD = Configs.SkippingMethods.findIndex((x) => x === configs.skippingMethod) + 1
        defines.GRADIENTS_METHOD = Configs.GradientsMethods.findIndex((x) => x === configs.gradientsMethod) + 1    
    }

    startIteratorDefines()
    {
        const computes = this.computes
        const defines = this.material.defines

        const sum = (y, x) => y + x
        defines.MAX_CELLS = computes.interpolationMap.dimensions.toArray().reduce(sum, 0)
        defines.MAX_BLOCKS = computes.occupancyMap.dimensions.toArray().reduce(sum, 0)
        defines.MAX_TRACES = defines.MAX_CELLS * 5

        defines.MAX_CELLS_PER_BLOCK = this.configs.blockSize * 3
        defines.MAX_TRACES_PER_BLOCK = defines.MAX_CELLS_PER_BLOCK * 5
        defines.MAX_GROUPS = Math.ceil(defines.MAX_CELLS / defines.MAX_CELLS_PER_BLOCK)
        defines.MAX_BLOCKS_PER_GROUP = Math.ceil(defines.MAX_BLOCKS / defines.MAX_GROUPS)
    }
  
    async onThresholdChange(threshold)
    {
        const uniforms = this.material.uniforms
        uniforms.u_rendering.value.isovalue = threshold
        await this.computes.onThresholdChange()
        await this.textures.onThresholdChange()

    }

    async onStrideChange(stride)
    {
        const uniforms = this.material.uniforms
        uniforms.u_distance_map.value.stride = stride
        await this.computes.onStrideChange()
        await this.textures.onStrideChange()
        
        // Update 
        uniforms.u_textures.value.occupancy = this.textures.occupancyMap
        uniforms.u_textures.value.isotropic_distance = this.textures.distanceMap
        uniforms.u_textures.value.anisotropic_distance = this.textures.anisotropicDistanceMap
        uniforms.u_textures.value.extended_distance = this.textures.extendedAnisotropicDistanceMap

        uniforms.u_volume.value.blocks.copy(this.computes.distanceMap.dimensions)
        uniforms.u_volume.value.stride = this.computes.distanceMap.stride

        // Defines
        const defines = this.material.defines
        defines.MAX_CELLS = this.computes.intensityMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_BLOCKS = this.computes.distanceMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_TRACES = defines.MAX_CELLS * 5
        defines.MAX_CELLS_PER_BLOCK = this.computes.distanceMap.stride * 3
        defines.MAX_TRACES_PER_BLOCK = defines.MAX_CELLS_PER_BLOCK * 5
        defines.MAX_GROUPS = Math.ceil(defines.MAX_CELLS / defines.MAX_CELLS_PER_BLOCK)
        defines.MAX_BLOCKS_PER_GROUP = Math.ceil(defines.MAX_BLOCKS / defines.MAX_GROUPS)

        this.material.needsUpdate = true
    }

    async onInterpolationChange(interpolationMethod)
    {
        this.material.defines.INTERPOLATION_METHOD = interpolationMethod
        await this.computes.onInterpolationChange()
        await this.textures.onInterpolationChange()

        this.material.needsUpdate = true
    }

    destroy() 
    {
        if (this.computes)
        {
            this.computes.destroy()
            this.computes = null
        }

        if (this.textures)
        {
            this.textures.destroy()
            this.textures = null
        }

        if (this.mesh) 
        {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
            this.mesh = null
        }
    
        if (this.gui) 
        {
            this.gui.destroy()
            this.gui = null
        }

        // Clean up references
        this.scene = null
        this.resources = null
        this.renderer = null
        this.camera = null
        this.sizes = null
        this.debug = null

        console.log("ISOViewer destroyed")
    } 
}