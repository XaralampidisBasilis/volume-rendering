import * as THREE from 'three'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import ISOMaterial from './ISOMaterial'
import ISOGui from './ISOGui'
import ISOComputes from './ISOComputes'
import ISOTextures from './ISOTextures'

export default class ISOViewer extends EventEmitter
{
    static instance = null

    constructor()
    {
        super()
   
        // singleton
        if (ISOViewer.instance) 
        {
            return ISOViewer.instance
        }
        ISOViewer.instance = this

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug
        this.configs = this.experience.configs
        this.material = ISOMaterial()
        this.computes = new ISOComputes()
        this.textures = new ISOTextures()

        // Wait for textures
        this.textures.on('ready', () =>
        {
            this.setGeometry()
            this.setMaterial()
            this.setMesh()

            this.gui = new ISOGui()
            this.trigger('ready')
            console.log('ISOViewer', this)
        })
    }

    start()
    {
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
    }

    startUniforms()
    {
        const uniforms = this.material.uniforms
        uniforms.u_textures.value.interpolation_map = this.computes.interpolationMap.texturesSync()
        uniforms.u_textures.value.occupancy_map = this.computes.occupancyMap.texturesSync()
        uniforms.u_textures.value.distance_map = this.computes.distanceMap.texturesSync()
        
        this.computes.interpolationMap.tensor.dispose()
        this.computes.occupancyMap.tensor.dispose()
        this.computes.distanceMap.tensor.dispose()
    }

    startDefines()
    {
        const defines = this.material.defines
        defines.MAX_CELLS = this.computes.interpolationMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_BLOCKS = this.computes.distanceMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_TRACES = defines.MAX_CELLS * 5
        defines.MAX_CELLS_PER_BLOCK = this.computes.distanceMap.blockSize * 3
        defines.MAX_TRACES_PER_BLOCK = defines.MAX_CELLS_PER_BLOCK * 5
        defines.MAX_GROUPS = Math.ceil(defines.MAX_CELLS / defines.MAX_CELLS_PER_BLOCK)
        defines.MAX_BLOCKS_PER_GROUP = Math.ceil(defines.MAX_BLOCKS / defines.MAX_GROUPS)
    }
  
    setGeometry()
    {
        this.geometry = new THREE.BoxGeometry(1, 1, 1)
    }

    setMaterial()
    {        
        // Uniforms
        const uniforms = this.material.uniforms
        const intensityMap = this.computes.intensityMap
        const distanceMap =  this.computes.distanceMap

        uniforms.u_textures.value.colormaps = this.textures.colorMaps   
        uniforms.u_textures.value.trilinear_volume = this.textures.intensityMap
        uniforms.u_textures.value.tricubic_volume = this.textures.trilaplacianIntensityMap
        uniforms.u_textures.value.occupancy = this.textures.occupancyMap
        uniforms.u_textures.value.isotropic_distance = this.textures.distanceMap
        uniforms.u_textures.value.anisotropic_distance = this.textures.anisotropicDistanceMap
        uniforms.u_textures.value.extended_distance = this.textures.extendedAnisotropicDistanceMap
        
        uniforms.u_volume.value.dimensions.copy(intensityMap.dimensions)
        uniforms.u_volume.value.inv_dimensions.copy(intensityMap.invDimensions)
        uniforms.u_volume.value.blocks.copy(distanceMap.dimensions)
        uniforms.u_volume.value.spacing.copy(intensityMap.spacing)
        uniforms.u_volume.value.size.copy(intensityMap.dimensions).multiply(intensityMap.spacing)
        uniforms.u_volume.value.anisotropy.copy(intensityMap.spacing).normalize()
        uniforms.u_volume.value.stride = distanceMap.stride

        const scale = new THREE.Matrix4().makeScale(...intensityMap.dimensions);
        const translate = new THREE.Matrix4().makeTranslation(0.5, 0.5, 0.5)
        uniforms.u_volume.value.grid_matrix.multiplyMatrices(scale, translate);

        // Defines
        const defines = this.material.defines
        defines.MAX_CELLS = intensityMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_BLOCKS = distanceMap.dimensions.toArray().reduce((s, x) => s + x, 0)
        defines.MAX_TRACES = defines.MAX_CELLS * 5
        defines.MAX_CELLS_PER_BLOCK = distanceMap.stride * 3
        defines.MAX_TRACES_PER_BLOCK = defines.MAX_CELLS_PER_BLOCK * 5
        defines.MAX_GROUPS = Math.ceil(defines.MAX_CELLS / defines.MAX_CELLS_PER_BLOCK)
        defines.MAX_BLOCKS_PER_GROUP = Math.ceil(defines.MAX_BLOCKS / defines.MAX_GROUPS)
    }

    setMesh()
    {   
        const size = this.computes.intensityMap.size

        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.scale.copy(size)
        this.scene.add(this.mesh)
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