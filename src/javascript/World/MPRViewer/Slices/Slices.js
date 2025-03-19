import * as THREE from 'three'
import Slice from './Slice'

const _plane = new THREE.Plane()
const _matrix = new THREE.Matrix4()
export default class Slices extends THREE.Group
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.parameters = viewer.processor.intensityMap.parameters

        this.setAxial()    // XY slice 
        this.setCoronal()  // XZ slice 
        this.setSagittal() // YZ slice 
        this.setGroup()
    }

    setGroup()
    {
        this.scale.copy(this.parameters.size)
        this.position.copy(this.parameters.size).divideScalar(2)
        this.renderOrder = 0
        this.visible = true
        this.update()

        this.viewer.add(this)
    }

    setAxial()
    {
        this.axial = new Slice(this.viewer)
        this.axial.plane.set(new THREE.Vector3(0, 0, 1), 0)
        this.axial.matrixAutoUpdate = false
        this.axial.name = 'axial'
        this.add(this.axial)
    }

    setCoronal()
    {
        this.coronal = new Slice(this.viewer)
        this.coronal.geometry.rotateX(Math.PI / 2)
        this.coronal.plane.set(new THREE.Vector3(0, 1, 0), 0)
        this.coronal.matrixAutoUpdate = false
        this.coronal.name = 'coronal'
        this.add(this.coronal)
    }

    setSagittal()
    {
        this.sagittal = new Slice(this.viewer)
        this.sagittal.geometry.rotateY(-Math.PI / 2)
        this.sagittal.plane.set(new THREE.Vector3(1, 0, 0), 0)
        this.sagittal.matrixAutoUpdate = false
        this.sagittal.name = 'sagittal'
        this.add(this.sagittal)
    }

    update()
    {
        this.updateMatrix()

        _matrix.makeScale(...this.parameters.invSpacing).multiply(this.matrix)

        this.children.forEach((slice) => 
        {                
            _plane.copy(slice.plane).applyMatrix4(_matrix)

            const uniforms = slice.material.uniforms
            uniforms.u_plane.value.hessian.set(..._plane.normal, _plane.constant)
            uniforms.u_plane.value.transform.copy(this.matrix)
        })
    }

    destroy()
    {
        if (this.axial)
        {
            this.axial.dispose()
            this.remove(this.axial)
        }

        if (this.coronal)
        {
            this.coronal.dispose()
            this.remove(this.coronal)
        }

        if (this.sagittal)
        {
            this.sagittal.dispose()
            this.remove(this.sagittal)
        }

        this.axial = null
        this.coronal = null
        this.sagittal = null

    }
}