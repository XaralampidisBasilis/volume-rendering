import * as THREE from 'three'
import Material from './Material'
import MPRViewer from '../MPRViewer'

export default class MPRSurface extends THREE.Mesh
{
    constructor()
    {
        // set mesh as unit box in [0, 1]
        const size = new THREE.Vector3(1, 1, 1)
        const offset = new THREE.Vector3(0.5, 0.5, 0.5)
        const geometry = new THREE.BoxGeometry(...size).translate(...offset)
        const material = Material()
        super(geometry, material)

        this.viewer = new MPRViewer()
        this.parameters = this.viewer.parameters

        this.setMaterial()
        this.setMesh()
    }

    setMesh()
    {   
        // scale mesh to [0, size]
        this.scale.copy(this.parameters.size)
        this.renderOrder = 1

        this.viewer.add(this)
    }

    setMaterial()
    {
        const textures = this.viewer.textures
        const computes = this.viewer.computes
        const uniforms = this.material.uniforms
        const defines = this.material.defines

        uniforms.u_textures.value.intensity_map = textures.intensityMap
        uniforms.u_textures.value.binary_map = textures.binaryMap
        uniforms.u_textures.value.distance_map = textures.distanceMap

        uniforms.u_volume.value.dimensions.copy(computes.intensityMap.parameters.dimensions)
        uniforms.u_volume.value.spacing.copy(computes.intensityMap.parameters.spacing)
        uniforms.u_volume.value.size.copy(computes.intensityMap.parameters.size)
        uniforms.u_volume.value.inv_dimensions.copy(computes.intensityMap.parameters.invDimensions)
        uniforms.u_volume.value.inv_spacing.copy(computes.intensityMap.parameters.invSpacing)
        uniforms.u_volume.value.inv_size.copy(computes.intensityMap.parameters.invSize)
        uniforms.u_volume.value.spacing_length = computes.intensityMap.parameters.spacingLength
        uniforms.u_volume.value.size_length = computes.intensityMap.parameters.sizeLength

        uniforms.u_bbox.value.dimensions.copy(computes.boundingBox.parameters.dimensions)
        uniforms.u_bbox.value.min_coords.copy(computes.boundingBox.parameters.minCoords)
        uniforms.u_bbox.value.max_coords.copy(computes.boundingBox.parameters.maxCoords)

        this.viewer.slices.children.forEach((slice, i) => 
        {
            uniforms.u_slices.value.hessian[i] = slice.material.uniforms.u_plane.value.hessian
            uniforms.u_slices.value.visible[i] = slice.material.uniforms.u_plane.value.visible
        })

        defines.MAX_VOXELS = computes.boundingBox.parameters.maxCells
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