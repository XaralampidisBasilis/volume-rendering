import * as THREE from 'three'
import Material from './Material'

export default class Surface extends THREE.Mesh
{
    constructor(viewer)
    {
        const size = viewer.processor.intensityMap.parameters.size
        const offset = size.clone().divideScalar(2)
        const geometry = new THREE.BoxGeometry(...size).translate(...offset)
        const material = Material()
        super(geometry, material)

        this.material.depthWrite = true
        this.material.depthTest = true
        this.material.transparent = true
        this.visible = true

        this.setUniforms(viewer)

        viewer.add(this)
    }

    setUniforms(viewer)
    {
        const textures = viewer.textures
        const processor = viewer.processor
        const uniforms = this.material.uniforms
        const defines = this.material.defines

        uniforms.u_textures.value.intensity_map = textures.intensityMap
        uniforms.u_textures.value.binary_map = textures.binaryMap
        uniforms.u_textures.value.distance_map = textures.distanceMap

        uniforms.u_volume.value.dimensions.copy(processor.intensityMap.parameters.dimensions)
        uniforms.u_volume.value.spacing.copy(processor.intensityMap.parameters.spacing)
        uniforms.u_volume.value.size.copy(processor.intensityMap.parameters.size)
        uniforms.u_volume.value.inv_dimensions.copy(processor.intensityMap.parameters.invDimensions)
        uniforms.u_volume.value.inv_spacing.copy(processor.intensityMap.parameters.invSpacing)
        uniforms.u_volume.value.inv_size.copy(processor.intensityMap.parameters.invSize)
        uniforms.u_volume.value.spacing_length = processor.intensityMap.parameters.spacingLength
        uniforms.u_volume.value.size_length = processor.intensityMap.parameters.sizeLength

        uniforms.u_bounding_box.value.dimensions.copy(processor.boundingBox.parameters.dimensions)
        uniforms.u_bounding_box.value.min_coords.copy(processor.boundingBox.parameters.minCoords)
        uniforms.u_bounding_box.value.max_coords.copy(processor.boundingBox.parameters.maxCoords)
        uniforms.u_bounding_box.value.min_position.copy(processor.boundingBox.parameters.minPosition)
        uniforms.u_bounding_box.value.max_position.copy(processor.boundingBox.parameters.maxPosition)

        viewer.slices.children.forEach((slice, i) => 
        {
            uniforms.u_slices.value.hessian[i] = slice.material.uniforms.u_plane.value.hessian
            uniforms.u_slices.value.visible[i] = slice.material.uniforms.u_plane.value.visible
        })

        defines.MAX_TRACES = processor.boundingBox.parameters.maxTraces
        defines.MAX_VOXELS = processor.boundingBox.parameters.maxCells
    }

    update()
    {
    }

    destroy()
    {
        this.geometry.dispose()
        this.material.dispose()
    }
}