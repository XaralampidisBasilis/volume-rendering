import * as THREE from 'three'
import * as CoordUtils from '../Utils/CoordUtils.js'

const _vector = new THREE.Vector3()

export default class Occumap 
{
    constructor(volumeDimensions, divisions)
    {
        if (divisions instanceof Number)
            this.divisions = new THREE.Vector3().setScalar(divisions)

        this.divisions = divisions.clone().clampScalar(2, volumeDimensions).round()
        this.volumeDimensions = volumeDimensions.clone()


        this.step = calculateStep(this.volumeDimensions, this.divisions)
        this.dimensions = calculateDimensions(this.volumeDimensions, this.step) 
        this.blocks = calculateBlocks(volumeDimensions, dimensions, step)
        this.data = this.initializeData(dimensions)
     
    }

    calculateStep(volumeDimensions, divisions)
    {
        return volumeDimensions.clone()
            .divideScalar(divisions)
            .ceil()
    }

    calculateDimensions(volumeDimensions, step) 
    {
        return volumeDimensions.clone()
            .divide(step)
            .ceil()
    }

    calculateBlocks(volumeDimensions, dimensions, step)
    {
        const blocks = []
        const voxelMax = volumeDimensions.clone().subScalar(1)

        for (let z = 0; z < dimensions.z; z++) {
            for (let y = 0; y < dimensions.y; y++) {
                for (let x = 0; x < dimensions.x; x++) {

                    const box = new THREE.Box3()

                    box.min.set(x, y, z).multiply(step)
                    box.max.set(x, y, z).addScalar(1).multiply(step).min(voxelMax)

                    blocks.push(box)
                }
            }
        }
    }

    initializeData(dimensions)
    {
        const count = dimensions.x * dimensions.y * dimensions.z
        return new Uint8Array(count).fill(1)
    }

    setData(array)
    {
        if (this.data.length !== array.length)

        for (let n = 0; n < this.array.length; n++)
            this.data[n] = array[n]
    }

    subdivide(subdivision)
    {
        if (subdivision instanceof Number)
            subdivision = new THREE.Vector3().setScalar(subdivision)
        
        subdivision.clampScalar(2, this.step).round()


        this.step = calculateStep(this.step, subdivision)
        this.dimensions = calculateDimensions(this.volumeDimensions, this.step) 


        const subBlockIndices = CoordUtils.findIndices(this.dimensions, subdivision)
        const flatten = new THREE.Vector3(1, this.dimensions.x, this.dimensions.x * this.dimensions.y)
        const block = new THREE.Vector3()

        for (block.z = 0; block.z < this.dimensions.z; block.z++) {
            for (block.y = 0; block.y < this.dimensions.y; block.y++) {
                for (block.x = 0; block.x < this.dimensions.x; block.x++) {


                    const offset = CoordUtils.sub2ind(this.dimensions, _vector)

                    for(let n = 0; n < subBlockIndices.length; n++)
                    {
                        subBlockIndices[n] + offset
                    }

                    this.blocks[n]
                }
            }
        }
    }


}