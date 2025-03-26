import * as THREE from 'three'
import Material from './Material'
import MPRViewer from '../MPRViewer'

const _matrix = new THREE.Matrix4()
const _plane = new THREE.Plane()

export default class Surface
{
    constructor()
    {
        this.viewer = new MPRViewer()
        this.parameters = this.viewer.parameters

        this.setGeometry()
        this.setMaterial()
        this.setMesh()
        this.update()
    }

    setGeometry()
    {
        const size = new THREE.Vector3().setScalar(1)
        const offset = new THREE.Vector3().setScalar(0.5)
        this.geometry = new THREE.BoxGeometry(...size).translate(...offset)
    }

    setMaterial()
    {
        this.material = Material()

        const textures = this.viewer.textures
        const uniforms = this.material.uniforms
        const defines = this.material.defines
        const computes = this.viewer.computes

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

        this.updateBboxUniforms()
        this.updateSlicesUniforms()

        defines.MAX_VOXELS = computes.boundingBox.parameters.maxCells
        
    }

    setMesh()
    {   
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.scale.copy(this.parameters.size)
        this.mesh.renderOrder = 1
    }

    update()
    {
    }

    updateSlicesUniforms()
    {    
        const uniforms = this.material.uniforms
        const slices = this.viewer.slices
        
        // create a transform from slices local coords to parent grid coords
        _matrix.makeScale(...this.parameters.invSpacing).multiply(slices.group.matrix)

        slices.planes.forEach((plane, i) => 
        {                
            // compute slice plane in parent grid coords
            _plane.copy(plane.local).applyMatrix4(_matrix)

            // update uniforms
            uniforms.u_slices.value.hessian[i].set(..._plane.normal, _plane.constant)
            uniforms.u_slices.value.visible[i] = slices.group.children[i].visible
        })
    }

    updateBboxUniforms()
    {
        const uniforms = this.material.uniforms
        const computes = this.viewer.computes

        uniforms.u_bbox.value.dimensions.copy(computes.boundingBox.parameters.dimensions)
        uniforms.u_bbox.value.min_coords.copy(computes.boundingBox.parameters.minCoords)
        uniforms.u_bbox.value.max_coords.copy(computes.boundingBox.parameters.maxCoords)
    }

    destroy()
    {
        this.geometry.dispose()
        this.material.dispose()
    }
}