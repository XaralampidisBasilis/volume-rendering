import * as THREE from 'three'
import { OBB } from 'three/addons/math/OBB.js'

export class Container
{
    constructor(size)
    {
        this.size = size
        this.setGeometry()
        this.setMaterial()
        this.setBox()
        this.setObb()
        this.setMesh()
        this.setHelper()
    }

    setGeometry()
    {
        this.geometry = new THREE.BoxGeometry(...this.size)
    }

    setMaterial()
    {
        this.material =  new THREE.MeshBasicMaterial()
        // this.material.color = 0x0055ff
        this.material.color = 0xff9999
        this.material.side = THREE.DoubleSide
        this.material.visible = true
        this.material.transparent = true
        this.material.opacity = 0.2
        this.material.depthTest = true
        this.material.depthWrite = true
    }

    setBox()
    {
        const center = new THREE.Vector3()
        this.box = new THREE.Box3().setFromCenterAndSize(center, this.size)
    }

    setObb()
    {
        this.obbLocal = new OBB().fromBox3(this.box)
        this.obbWorld = new OBB().copy(this.obbLocal)
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
    }

    setHelper()
    {
        this.helper = new THREE.Box3Helper(this.box, this.material.color)
        this.mesh.add(this.helper)
    }

    intersect(raycaster)
    {
        const intersections = raycaster.intersectObject(this.mesh, false).filter((result, i) => 
        {
            const distance = result.distance
            return !intersections.slice(i + 1).some((result) => Math.abs(result.distance - distance) < 1e-6)
        })
    
        return intersections
    }

    update()
    {
        this.obbWorld.copy(this.obbLocal).applyMatrix4(this.container.mesh.matrixWorld)
    }

    destroy()
    {

    }
}
