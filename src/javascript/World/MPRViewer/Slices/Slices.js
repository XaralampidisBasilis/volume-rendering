import * as THREE from 'three'
import Slice from './Slice'

const _plane = new THREE.Plane()
export default class Slices extends THREE.Group
{
    constructor()
    {
        super()

        this.setAxial() // XY slice 
        this.setCoronal() // XZ slice 
        this.setSagittal() // YZ slice 
    }

    setAxial()
    {
        const normal = new THREE.Vector3(0, 0, 1)
        const constant = 0

        this.axial = new Slice()
        this.axial.name = 'axial'
        this.axial.geometry.dispose()
        this.axial.geometry = new THREE.PlaneGeometry(1, 1)
        this.axial.plane = new THREE.Plane(normal, constant)
        this.axial.matrixAutoUpdate = false

        this.add(this.axial)
    }

    setCoronal()
    {
        const normal = new THREE.Vector3(0, 1, 0)
        const constant = 0

        this.coronal = new Slice()
        this.coronal.name = 'coronal'
        this.coronal.geometry.dispose()
        this.coronal.geometry = new THREE.PlaneGeometry(1, 1).rotateX(Math.PI / 2)
        this.coronal.plane = new THREE.Plane(normal, constant)
        this.coronal.matrixAutoUpdate = false

        this.add(this.coronal)
    }

    setSagittal()
    {
        const normal = new THREE.Vector3(1, 0, 0)
        const constant = 0

        this.sagittal = new Slice()
        this.sagittal.name = 'sagittal'
        this.sagittal.geometry.dispose()
        this.sagittal.geometry = new THREE.PlaneGeometry(1, 1).rotateY(-Math.PI / 2)
        this.sagittal.plane = new THREE.Plane(normal, constant)
        this.sagittal.matrixAutoUpdate = false

        this.add(this.sagittal)
    }

    updateSlices()
    {
        this.updateMatrix()

        this.children.forEach((slice) => 
        {
            _plane.copy(slice.plane).applyMatrix4(this.matrix).normalize()

            const uniforms = slice.material.uniforms
            uniforms.u_slice.value.hessian.set(_plane.normal, _plane.constant)
            uniforms.u_slice.value.transform.copy(this.matrix)
        })
    }

    destroy()
    {
        if (this.axial)
        {
            this.remove(this.axial)
            this.axial.destroy()
            this.axial = null
        }

        if (this.coronal)
        {
            this.remove(this.coronal)
            this.coronal.destroy()
            this.coronal = null
        }

        if (this.sagittal)
        {
            this.remove(this.sagittal)
            this.sagittal.destroy()
            this.sagittal = null
        }
    }
}