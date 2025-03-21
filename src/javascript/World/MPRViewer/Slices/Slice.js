import * as THREE from 'three'
import Material from './Material'
import MPRViewer from '../MPRViewer'

export default class Slice 
{
    constructor()
    {
        this.viewer = new MPRViewer()

        this.setGeometry()
        this.setMaterial()
        this.setMesh()
    }

    setGeometry()
    {
        const length = this.viewer.parameters.sizeLength * 2
        this.geometry = new THREE.PlaneGeometry(length, length)
    }

    setMaterial()
    {
        this.material = new Material()

        const uniforms = this.material.uniforms
        const textures = this.viewer.textures
        const computes = this.viewer.computes

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

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
    }

    destroy()
    {
        this.geometry.dispose()
        this.material.dispose()

        this.viewer = null
        this.geometry = null
        this.material = null
        this.mesh = null
    }
}