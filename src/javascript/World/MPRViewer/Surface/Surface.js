import * as THREE from 'three'
import Material from './Material'
import Experience from '../../Experience'

export default class Surface
{
    constructor(viewer)
    {
        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.instance = new THREE.Object3D()
    }

    setSlices()
    {
    }
}