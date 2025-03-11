import * as THREE from 'three'
import Slice from './Slice'

const _plane = new THREE.Plane()
const _point = new THREE.Vector3()
const _normal = new THREE.Vector3()
export default class Slices extends THREE.Group
{
    constructor(viewer)
    {
        super()

        this.setAxial(viewer)    // XY slice 
        this.setCoronal(viewer)  // XZ slice 
        this.setSagittal(viewer) // YZ slice 
        this.add(this.axial)
        this.add(this.coronal)
        this.add(this.sagittal)

        this.viewer = viewer
        this.parameters = viewer.processor.intensityMap.parameters
        this.position.copy(this.parameters.size).divideScalar(2)
        this.update()
        this.visible = true
        
        viewer.add(this)
    }

    setAxial(viewer)
    {
        this.axial = new Slice(viewer)
        this.axial.plane.set(new THREE.Vector3(0, 0, 1), 0)
        this.axial.matrixAutoUpdate = false
        this.axial.name = 'axial'
    }

    setCoronal(viewer)
    {
        this.coronal = new Slice(viewer)
        this.coronal.geometry.rotateX(Math.PI / 2)
        this.coronal.plane.set(new THREE.Vector3(0, 1, 0), 0)
        this.coronal.matrixAutoUpdate = false
        this.coronal.name = 'coronal'
    }

    setSagittal(viewer)
    {
        this.sagittal = new Slice(viewer)
        this.sagittal.geometry.rotateY(-Math.PI / 2)
        this.sagittal.plane.set(new THREE.Vector3(1, 0, 0), 0)
        this.sagittal.matrixAutoUpdate = false
        this.sagittal.name = 'sagittal'
    }

    update()
    {
        this.updateMatrix()

        _point.copy(this.position).multiply(this.parameters.invSize)

        this.children.forEach((slice) => 
        {            
            _normal.copy(slice.plane.normal).applyMatrix4(this.matrix)
            _normal.multiply(this.parameters.invSize).normalize()
            
            _plane.setFromNormalAndCoplanarPoint(_normal, _point)

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