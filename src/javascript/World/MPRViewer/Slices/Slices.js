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
        this.scene = this.viewer.scene
        this.parameters = this.viewer.parameters
        this.raycaster = this.viewer.camera.raycaster
        
        
        this.setAxial()    
        this.setCoronal() 
        this.setSagittal() 
        this.setGroup()
        this.setPlanes()
        this.setBox()
        this.update()
    }

    setAxial()
    {
        this.axial = new Slice() 
    }

    setCoronal()
    {
        this.coronal = new Slice()  
        this.coronal.mesh.geometry.rotateX(Math.PI / 2)
    }

    setSagittal()
    {
        this.sagittal = new Slice() 
        this.sagittal.mesh.geometry.rotateY(-Math.PI / 2)
    }

    setGroup()
    {   
        this.group = new THREE.Group()
        this.group.position.copy(this.parameters.size).divideScalar(2)
        this.group.renderOrder = 0
        this.group.add(this.axial.mesh)
        this.group.add(this.coronal.mesh)
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
        this.group.updateMatrixWorld(true)
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
        this.group.children.forEach((child, i) => 
        {                
            _plane.copy(this.planes[i].local).applyMatrix4(this.group.matrix)

            const uniforms = child.material.uniforms
            uniforms.u_slice.value.hessian.set(..._plane.normal, _plane.constant)
            uniforms.u_slice.value.matrix.copy(this.group.matrix)
            uniforms.u_slice.value.visible = child.visible
        })
    }

    intersect() 
    {
        const { ray } = this.raycaster
        
        let closest = null
        
        for (const plane of this.planes) 
        {
            // compute ray-plane distance
            const distance = ray.distanceToPlane(plane)

            if (distance !== null && distance >= 0) 
            {
                // compute ray-plane intersection point
                ray.at(distance,  new THREE.Vector3())

                if (this.box.containsPoint(point) && (! closest || distance < closest.distance)) 
                {
                    const normal = plane.normal.clone()

                    // update the closest intersection point
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
            this.axial.destroy()
            this.remove(this.axial)
        }

        if (this.coronal)
        {
            this.coronal.destroy()
            this.remove(this.coronal)
        }

        if (this.sagittal)
        {
            this.sagittal.destroy()
            this.remove(this.sagittal)
        }

        this.axial = null
        this.coronal = null
        this.sagittal = null
        this.group = null
        this.planes = null
        this.box = null
    }
}