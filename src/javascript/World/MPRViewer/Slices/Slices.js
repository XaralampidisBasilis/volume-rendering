import * as THREE from 'three'
import Slice from './Slice'

export default class Slices extends THREE.Group
{
    constructor()
    {
        super()

        this.setSlices()
    }

    setSlices()
    {
        const axial = new Slice()
        const coronal = new Slice()
        const sagittal = new Slice()

        // add names to the meshes
        axial.name = 'axial'
        coronal.name = 'coronal'
        sagittal.name = 'sagittal'

        // rotate planes from XY to get the rest
        coronal.rotateX(-Math.PI / 2) // XZ
        sagittal.rotateY(Math.PI / 2) // YZ 

        // bring planes center to the center of the unit cube
        axial.position.set(0.5, 0.5, 0.5) 
        coronal.position.set(0.5, 0.5, 0.5) 
        sagittal.position.set(0.5, 0.5, 0.5)

        // update local transformation
        axial.updateMatrix()
        coronal.updateMatrix()
        sagittal.updateMatrix()

        // apply the transformations to the assigned planes
        axial.plane.applyMatrix4(axial.matrix)
        coronal.plane.applyMatrix4(coronal.matrix)
        sagittal.plane.applyMatrix4(sagittal.matrix)

        this.add(axial)
        this.add(coronal)
        this.add(sagittal)

        // add small offset to avoid z-fighting artifacts
        axial.position.z += 0.001
        coronal.position.y += 0.001
        sagittal.position.x += 0.001

        // specify manually the render order to avoid intersection artifacts
        axial.renderOrder = 1
        coronal.renderOrder = 2
        sagittal.renderOrder = 3
    }
}