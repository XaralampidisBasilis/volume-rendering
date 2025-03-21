import * as THREE from 'three'
import Material from './Material'

export default class Slice extends THREE.Mesh
{
    constructor(viewer)
    {
        const length = Math.sqrt(3) * 2
        const geometry = new THREE.PlaneGeometry(length, length)
        const material = new Material()
        super(geometry, material)

        this.setPlane()
        this.setUniforms(viewer)
    }

    setPlane()
    {
        const constant = 0
        const normal = new THREE.Vector3(0, 0, 1)
        this.plane = new THREE.Plane(normal, constant)
    }

    setUniforms(viewer)
    {
        const textures = viewer.textures
        const computes = viewer.computes
        const uniforms = this.material.uniforms

        uniforms.u_textures.value.color_maps = textures.colorMaps
        uniforms.u_textures.value.intensity_map = textures.intensityMap
        uniforms.u_textures.value.binary_map = textures.binaryMap

        uniforms.u_volume.value.dimensions.copy(computes.intensityMap.parameters.dimensions)
        uniforms.u_volume.value.spacing.copy(computes.intensityMap.parameters.spacing)
        uniforms.u_volume.value.size.copy(computes.intensityMap.parameters.size)
        uniforms.u_volume.value.inv_dimensions.copy(computes.intensityMap.parameters.invDimensions)
        uniforms.u_volume.value.inv_spacing.copy(computes.intensityMap.parameters.invSpacing)
        uniforms.u_volume.value.inv_size.copy(computes.intensityMap.parameters.invSize)
        uniforms.u_volume.value.spacing_length = computes.intensityMap.parameters.spacingLength
        uniforms.u_volume.value.size_length = computes.intensityMap.parameters.sizeLength
    }

    destroy()
    {
        this.geometry.dispose()
        this.material.dispose()
    }
}