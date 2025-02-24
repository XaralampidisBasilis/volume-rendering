import * as THREE from 'three'
import MPRMaterial from './MPRMaterial'
import Experience from '../../Experience'

export default class MPRPlane
{
    constructor()
    {
        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
    }

    setGeometry()
    {
        this.geometry = THREE.PlaneGeometry()
    }

    setMaterial()
    {
        this.material = MPRMaterial()
    }

    setMesh()
    {

    }
}