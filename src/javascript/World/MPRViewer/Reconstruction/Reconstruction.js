import * as THREE from 'three'
import Slice from './Slice'
import Experience from '../../Experience'

export default class Reconstruction
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
        new Slice()
    }
}