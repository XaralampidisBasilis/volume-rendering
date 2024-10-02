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
        this.mesh.add(new THREE.AxesHelper(0.2));
    }
}