import * as THREE from 'three'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import Configs from '../../Utils/Configs'
import ISOMaterial from './ISOMaterial'

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

    start()
    {
        this.setMaterial()
        this.size = this.computes.volumeMap.size
        this.mesh.scale.copy(this.size)
        console.log(this)
    }

    setMesh()
    {   
        this.material = ISOMaterial()
        this.uniforms = this.material.uniforms
        this.defines = this.material.defines

        this.geometry = new THREE.BoxGeometry(1, 1, 1)
        this.mesh = new THREE.Mesh(this.geometry, this.material)
       
    }

    setMaterial()
    {
        const translation = new THREE.Matrix4().makeTranslation(0.5, 0.5, 0.5)
        const scale = new THREE.Matrix4().makeScale(...this.computes.volumeMap.dimensions)
        this.material.uniforms.uCustomModelMatrix.value.multiplyMatrices(scale, translation)

        this.setDefinesMethods()
        this.setDefinesIterators()
        this.setUniformsTextures()
        this.setUniformsVolume()
        this.setUniformsBoundingBox()
        this.setUniformsDebug()
        this.setUniformsShading()

    }

    setDefinesMethods()
    {
        const configs = this.configs
        const defines = this.material.defines
        defines.MARCHING_METHOD = Configs.MarchingMethods.findIndex((x) => x === configs.marchingMethod)
        defines.INTERPOLATION_METHOD = Configs.InterpolationMethods.findIndex((x) => x === configs.interpolationMethod)
        defines.SKIPPING_METHOD = Configs.SkippingMethods.findIndex((x) => x === configs.skippingMethod)
        defines.GRADIENTS_METHOD = Configs.GradientsMethods.findIndex((x) => x === configs.gradientsMethod)  
        this.material.needsUpdate = true
    }

    setDefinesIterators()
    {        
        const sum = (y, x) => y + x
        const defines = this.material.defines
        defines.MAX_CELLS = this.computes.volumeMap.dimensions.toArray().reduce(sum, 0)
        defines.MAX_BLOCKS = this.computes.occupancyMap.dimensions.toArray().reduce(sum, 0)
        defines.MAX_TRACES = defines.MAX_CELLS * 5
        defines.MAX_CELLS_PER_BLOCK = this.configs.blockSize * 3
        defines.MAX_TRACES_PER_BLOCK = defines.MAX_CELLS_PER_BLOCK * 5
        defines.MAX_GROUPS = Math.ceil(defines.MAX_CELLS / defines.MAX_CELLS_PER_BLOCK)
        defines.MAX_BLOCKS_PER_GROUP = Math.ceil(defines.MAX_BLOCKS / defines.MAX_GROUPS)
        this.material.needsUpdate = true
    }

    setUniformsTextures()
    {
        const uniforms = this.material.uniforms
        uniforms.u_textures.value.interpolation_map = this.computes.interpolationMap.texture
        uniforms.u_textures.value.occupancy_map = this.computes.occupancyMap.texture
        uniforms.u_textures.value.distance_map = this.computes.distanceMap.texture
    }

    setUniformsVolume()
    {
        const uniforms = this.material.uniforms
        uniforms.u_volume.value.isovalue = this.configs.isosurfaceValue
        uniforms.u_volume.value.dimensions.copy(this.computes.volumeMap.dimensions)
        uniforms.u_volume.value.spacing.copy(this.computes.volumeMap.spacing).normalize()
        uniforms.u_volume.value.block_size = this.configs.blockSize
        uniforms.u_volume.value.blocked_dimensions.copy(this.computes.occupancyMap.dimensions)
        uniforms.u_volume.value.inv_dimensions.fromArray(uniforms.u_volume.value.dimensions.toArray().map(x => 1/x))
    }

    setUniformsBoundingBox()
    {
        const minCoords = new THREE.Vector3(0)
        const maxCoords = new THREE.Vector3(...this.computes.volumeMap.dimensions)

        const blockSize = this.configs.blockSize
        const minBlockCoords = this.computes.occupancyMap.boundingBox.minCoords
        const maxBlockCoords = this.computes.occupancyMap.boundingBox.maxCoords

        const uniforms = this.material.uniforms
        uniforms.u_bbox.value.min_position.fromArray(minBlockCoords).addScalar(0).multiplyScalar(blockSize).subScalar(0.5).clamp(minCoords, maxCoords)
        uniforms.u_bbox.value.max_position.fromArray(maxBlockCoords).addScalar(1).multiplyScalar(blockSize).subScalar(0.5).clamp(minCoords, maxCoords)
    }

    setUniformsShading()
    {
        const uniforms = this.material.uniforms
        uniforms.u_shading.value.colormap = Configs.Colormaps.findIndex((x) => x === this.configs.colormap)
        uniforms.u_shading.value.shininess = 40.0,
        uniforms.u_shading.value.reflect_ambient = 0.2
        uniforms.u_shading.value.reflect_diffuse = 1.0
        uniforms.u_shading.value.reflect_specular = 0.6
        uniforms.u_shading.value.modulate_edges = 1.0,
        uniforms.u_shading.value.modulate_gradient  = 1.0
        uniforms.u_shading.value.modulate_curvature = 1.0
    }

    setUniformsDebug()
    {
        const uniforms = this.material.uniforms
        uniforms.u_debug.value.max_groups = this.material.defines.MAX_GROUPS
        uniforms.u_debug.value.max_blocks = this.material.defines.MAX_BLOCKS_PER_GROUP 
        uniforms.u_debug.value.max_cells  = this.material.defines.MAX_CELLS_PER_BLOCK  
    }

    change(event)
    {
        if      (event.key === 'isosurfaceValue'    ) this.onChangeIsosurfaceValue(event)
        else if (event.key === 'blockSize'          ) this.onChangeBlockSize(event)
        else if (event.key === 'downscaleFactor'    ) this.onChangeDownscaleFactor(event)
        else if (event.key === 'interpolationMethod') this.onChangeInterpolationMethod(event)
        else if (event.key === 'skippingMethod'     ) this.onChangeSkippingMethod(event)
        else if (event.key === 'gradientsMethod'    ) this.onChangeGradientsMethod(event)
        else if (event.key === 'marchingMethod'     ) this.onChangeMarchingMethod(event)
        else if (event.key === 'skippingEnabled'    ) this.onChangeSkippingEnabled(event)
        else if (event.key === 'bernsteinEnabled'   ) this.onChangeBernsteinEnabled(event)
        else if (event.key === 'boundingBoxEnabled' ) this.onChangeBoundingBoxEnabled(event)
        else if (event.key === 'colormap'           ) this.onChangeColormap(event)
        
        console.log(this)
    }

    onChangeIsosurfaceValue(event)
    {
        const uniforms = this.material.uniforms
        uniforms.u_volume.value.isovalue = this.configs.isosurfaceValue
        this.setUniformsBoundingBox()
    }

    onChangeBlockSize(event)
    {
        const uniforms = this.material.uniforms
        uniforms.u_volume.value.block_size = this.configs.blockSize
        uniforms.u_volume.value.blocked_dimensions.copy(this.computes.occupancyMap.dimensions)
        uniforms.u_textures.value.occupancy_map.dispose()
        uniforms.u_textures.value.distance_map.dispose()
        uniforms.u_textures.value.occupancy_map = this.computes.occupancyMap.texture
        uniforms.u_textures.value.distance_map = this.computes.distanceMap.texture
        this.setUniformsBoundingBox()
        this.setDefinesIterators()
    }

    onChangeDownscaleFactor(event)
    {
        const uniforms = this.material.uniforms
        uniforms.u_textures.value.interpolation_map.dispose()
        uniforms.u_textures.value.occupancy_map.dispose()
        uniforms.u_textures.value.distance_map.dispose()

        this.material.dispose()
        this.setMaterial()
    }

    onChangeInterpolationMethod(event)
    {
        const uniforms = this.material.uniforms
        uniforms.u_textures.value.occupancy_map = this.computes.occupancyMap.texture
        uniforms.u_textures.value.distance_map = this.computes.distanceMap.texture
        this.setUniformsBoundingBox()

        this.material.defines.INTERPOLATION_METHOD = Configs.InterpolationMethods.findIndex((x) => x === this.configs.interpolationMethod)
        this.material.needsUpdate = true
    }

    onChangeSkippingMethod(event)
    {
        this.material.uniforms.u_textures.value.distance_map = this.computes.distanceMap.texture
        this.material.defines.SKIPPING_METHOD = Configs.SkippingMethods.findIndex((x) => x === this.configs.skippingMethod)
        this.material.needsUpdate = true
    }

    onChangeGradientsMethod(event)
    {
        this.material.defines.GRADIENTS_METHOD = Configs.GradientsMethods.findIndex((x) => x === this.configs.gradientsMethod)
        this.material.needsUpdate = true
    }

    onChangeMarchingMethod(event)
    {
        this.material.defines.MARCHING_METHOD = Configs.MarchingMethods.findIndex((x) => x === this.configs.marchingMethod)
        this.material.needsUpdate = true
    }

    onChangeSkippingEnabled(event)
    {
        this.material.defines.SKIPPING_ENABLED = Number(this.configs.skippingEnabled)
        this.material.needsUpdate = true
    }

    onChangeBernsteinEnabled(event)
    {
        this.material.defines.BERNSTEIN_ENABLED = Number(this.configs.bernsteinEnabled)
        this.material.needsUpdate = true
    }

    onChangeBoundingBoxEnabled(event)
    {
        this.material.defines.BBOX_ENABLED = Number(this.configs.boundingBoxEnabled)
        this.material.needsUpdate = true
    }

    onChangeColormap(event)
    {
        this.material.uniforms.u_shading.value.colormap = Configs.Colormaps.findIndex((x) => x === this.configs.colormap)
    }

    destroy() 
    {
        if (this.mesh) 
        {
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
            this.mesh = null
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