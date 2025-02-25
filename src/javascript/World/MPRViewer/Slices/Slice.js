import * as THREE from 'three'
import Material from './Material'

export default class Slice extends THREE.Mesh
{
    constructor()
    {
        super() 

        this.setGeometry()
        this.setMaterial()
        this.setPlane()
    }

    setGeometry()
    {
        this.geometry.dispose() 
        this.geometry = new THREE.PlaneGeometry(1, 1)
    }

    setMaterial()
    {
        this.material.dispose() 
        this.material = Material()
    }

    setPlane()
    {
        const constant = 0
        const normal = new THREE.Vector3(0, 0, 1)
        this.plane = new THREE.Plane(normal, constant) // XY plane centered at origin with orientation at +Z
    }

    destroy() 
    {
        if (this.geometry) 
        {
            this.geometry.dispose()
            this.geometry = null
        }

        if (this.material) 
        {
            this.material.dispose() 
            this.material = null
        }

        this.plane = null
    }
}
