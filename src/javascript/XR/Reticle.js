import * as THREE from 'three'

export default class Reticle
{
    constructor()
    {
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
    }

    setGeometry()
    {
        this.geometry = new THREE.RingGeometry(0.15, 0.2, 32)
        this.geometry.rotateX(- Math.PI / 2)
    }

    setMaterial()
    {
        this.material = new THREE.MeshBasicMaterial({
            color: 0xffffff,
            transparent: true,
            opacity: 0.7,
            side: THREE.DoubleSide
        })
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.add(new THREE.AxesHelper(0.2))
    }

    destroy()
    {
        if (this.mesh) {

            if (this.geometry) {
                this.geometry.dispose()
                this.geometry = null
            }
            if (this.material) {
                this.material.dispose()
                this.material = null
            }

            this.mesh.traverse((child) => 
            {
                if (child instanceof THREE.AxesHelper) 
                    this.mesh.remove(child)
                
            })

            this.mesh = null
        }
    }
}