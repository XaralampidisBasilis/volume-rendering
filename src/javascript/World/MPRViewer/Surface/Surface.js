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

        this.setUniforms(viewer)
    }

    setUniforms(viewer)
    {
        const textures = viewer.textures
        const processor = viewer.processor
        const uniforms = this.material.uniforms

        uniforms.u_textures.value.color_maps = textures.colorMaps
        uniforms.u_textures.value.intensity_map = textures.intensityMap
        uniforms.u_textures.value.binary_map = textures.binaryMap

        uniforms.u_intensity_map.value.dimensions.copy(processor.intensityMap.parameters.dimensions)
        uniforms.u_intensity_map.value.spacing.copy(processor.intensityMap.parameters.spacing)
        uniforms.u_intensity_map.value.size.copy(processor.intensityMap.parameters.size)
        uniforms.u_intensity_map.value.inv_dimensions.copy(processor.intensityMap.parameters.invDimensions)
        uniforms.u_intensity_map.value.inv_spacing.copy(processor.intensityMap.parameters.invSpacing)
        uniforms.u_intensity_map.value.inv_size.copy(processor.intensityMap.parameters.invSize)
        uniforms.u_intensity_map.value.spacing_length = processor.intensityMap.parameters.spacingLength
        uniforms.u_intensity_map.value.size_length = processor.intensityMap.parameters.sizeLength

        uniforms.u_binary_map.value.dimensions.copy(processor.binaryMap.parameters.dimensions)
        uniforms.u_binary_map.value.spacing.copy(processor.binaryMap.parameters.spacing)
        uniforms.u_binary_map.value.size.copy(processor.binaryMap.parameters.size)
        uniforms.u_binary_map.value.inv_dimensions.copy(processor.binaryMap.parameters.invDimensions)
        uniforms.u_binary_map.value.inv_spacing.copy(processor.binaryMap.parameters.invSpacing)
        uniforms.u_binary_map.value.inv_size.copy(processor.binaryMap.parameters.invSize)
        uniforms.u_binary_map.value.spacing_length = processor.binaryMap.parameters.spacingLength
        uniforms.u_binary_map.value.size_length = processor.binaryMap.parameters.sizeLength

        uniforms.u_bounding_box.value.dimensions.copy(processor.boundingBox.parameters.dimensions)
        uniforms.u_bounding_box.value.min_coords.copy(processor.boundingBox.parameters.minCoords)
        uniforms.u_bounding_box.value.max_coords.copy(processor.boundingBox.parameters.maxCoords)
        uniforms.u_bounding_box.value.min_position.copy(processor.boundingBox.parameters.minPosition)
        uniforms.u_bounding_box.value.max_position.copy(processor.boundingBox.parameters.maxPosition)
    }

    update()
    {
    }

    destroy()
    {
    }
}