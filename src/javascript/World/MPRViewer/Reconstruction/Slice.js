import * as THREE from 'three'
import Material from './Material'
import Experience from '../../Experience'

export default class Slice
{
    constructor()
    {
        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
    }

    setGeometry()
    {
        this.geometry = THREE.PlaneGeometry()
    }

    setMaterial()
    {
        this.material = Material()
    }

    setPlane()
    {
        
    }

    setMesh()
    {

    }
}