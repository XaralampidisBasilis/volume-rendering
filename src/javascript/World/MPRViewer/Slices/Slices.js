import * as THREE from 'three'
import Slice from './Slice'
import { OBB } from 'three/addons/math/OBB.js'
import { dominantAxis } from '../../../Utils/VectorUtils'

const _plane = new THREE.Plane()
const _matrix = new THREE.Matrix4()
export default class Slices extends THREE.Group
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.parameters = viewer.processor.intensityMap.parameters
        this.raycaster = this.viewer.experience.camera.raycaster
        
        this.setAxial()    // XY slice 
        this.setCoronal()  // XZ slice 
        this.setSagittal() // YZ slice 
        this.setBoundingBox()
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

    setBoundingBox()
    {
        const center = new THREE.Vector3()
        const box3 = new THREE.Box3().setFromCenterAndSize(center, this.parameters.size)
        this.boundingBox = new OBB().fromBox3(box3).applyMatrix4(this.matrixWorld)
        this.boundingBox.local = new OBB().fromBox3(box3)
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
        // update plane uniforms to parent grid coordinates

        this.updateMatrix()

        _matrix.makeScale(...this.parameters.invSpacing).multiply(this.matrix)

        this.children.forEach((slice) => 
        {                
            _plane.copy(slice.plane).applyMatrix4(_matrix)

            const uniforms = slice.material.uniforms
            uniforms.u_plane.value.hessian.set(..._plane.normal, _plane.constant)
            uniforms.u_plane.value.transform.copy(this.matrix)
        })

        // update boundingBox to world coordinates

        this.boundingBox.copy(this.boundingBox.local).applyMatrix4(this.matrixWorld)
    }

    intersect()
    {
        // compute intersection to world coordinates
        // const intersections = raycaster.intersectObjects(this.children, true).filter((intersection) => 
        // {
        //     return this.boundingBox.containsPoint(intersection.point)
        // })
        const intersection = this.raycaster.intersectObjects(this.children, true)[0]
        if (intersection)
        {

            console.log(intersection.point)


            // // convert intersection to local coordinates 
            // const point = this.worldToLocal(intersection.point.clone())
            // const axis = dominantAxis(point)
            // const pivot = point.clone().projectOnVector(axis)

            // // compute pivot and axis
            // intersection.pivot = pivot.applyMatrix4(this.matrixWorld)
            // intersection.axis = axis.clone().transformDirection(this.matrixWorld)
        }
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