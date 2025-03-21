import * as THREE from 'three'
import Slice from './Slice'
import Gui from './Gui'
import MPRViewer from '../MPRViewer'
import { OBB } from 'three/addons/math/OBB.js'

const _plane = new THREE.Plane()

export default class Slices
{
    constructor()
    {
        this.viewer = new MPRViewer()
        this.parameters = this.viewer.parameters
        this.raycaster = this.viewer.camera.raycaster
        this.gui = new Gui()
        
        this.setGroup()
        this.setAxial()    
        this.setCoronal() 
        this.setSagittal() 
        this.setPlanes()
        this.setBox()
    }

    setGroup()
    {   
        this.group = new THREE.Group()
        this.group.renderOrder = 0
        this.group.visible = true
        this.group.position.copy(this.parameters.size).divideScalar(2)
        this.group.updateMatrixWorld(true)
        this.viewer.group.add(this.group)
    }

    setAxial()
    {
        this.axial = new Slice() 
        this.axial.mesh.matrixAutoUpdate = false
        this.group.add(this.axial.mesh)
    }

    setCoronal()
    {
        this.coronal = new Slice()  
        this.coronal.mesh.geometry.rotateX(Math.PI / 2)
        this.coronal.mesh.matrixAutoUpdate = false
        this.group.add(this.coronal.mesh)
    }

    setSagittal()
    {
        this.sagittal = new Slice() 
        this.sagittal.mesh.geometry.rotateY(-Math.PI / 2)
        this.sagittal.mesh.matrixAutoUpdate = false
        this.group.add(this.sagittal.mesh)
    }

    setPlanes()
    {
        const normals = [
            new THREE.Vector3(0, 0, 1),
            new THREE.Vector3(0, 1, 0),
            new THREE.Vector3(1, 0, 0),
        ]

        this.planes = normals.map((normal) =>
        {
            const constant = 0
            const plane = new THREE.Plane(normal, constant).applyMatrix4(this.group.matrixWorld) // world coords
            plane.local = new THREE.Plane(normal, constant) // local coords

            return plane
        })
    }
    
    setBox()
    {
        const center = new THREE.Vector3()
        const size = new THREE.Vector3().copy(this.parameters.size)
        const box = new THREE.Box3().setFromCenterAndSize(center, size)

        this.box = new OBB().fromBox3(box).applyMatrix4(this.group.matrixWorld) // world coords
        this.box.local = new OBB().fromBox3(box) // local coords
    }

    update()
    {
        this.updateMatrixWord(true)
        this.updatePlanesToWorld()
        this.updateBoxToWorld()
        this.updateSliceUniforms()
    }

    updatePlanesToWorld()
    {
        this.planes.forEach((plane) => 
        {
            plane.copy(plane.local).applyMatrix4(this.group.matrixWorld)
        })
    }

    updateBoxToWorld()
    {
        this.box.copy(this.box.local).applyMatrix4(this.group.matrixWorld)
    }

    updateSliceUniforms()   
    {
        this.group.children.forEach((slice, i) => 
        {                
            _plane.copy(this.planes[i].local).applyMatrix4(this.group.matrix)

            const uniforms = slice.mesh.material.uniforms
            uniforms.u_slice.value.hessian.set(..._plane.normal, _plane.constant)
            uniforms.u_slice.value.matrix.copy(this.group.matrix)
            uniforms.u_slice.value.visible = slice.mesh.visible
        })
    }

    intersect(raycaster) 
    {
        const { ray } = raycaster
        let closest = null
    
        for (const plane of this.planes) 
        {
            // compute ray plane distance
            const distance = ray.distanceToPlane(plane)

            if (distance && distance > 0) 
            {
                // compute ray plane intersection point
                const point = ray.at(distance, new THREE.Vector3())

                if (this.box.containsPoint(point) && closest && distance < closest.distance) 
                {
                    // update the closest intersection point
                    const normal = plane.normal.clone()
                    closest = { point, distance, normal }
                }
            }
        }
    
        return closest
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