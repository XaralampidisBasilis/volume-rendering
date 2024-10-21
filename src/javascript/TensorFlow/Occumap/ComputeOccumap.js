import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeOccumap
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.minCoords = this.viewer.material.uniforms.u_occupancy.value.min_coords
        this.maxCoords = this.viewer.material.uniforms.u_occupancy.value.max_coords
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            // const sliceBegin = [...this.minCoords.toArray().toReversed(), 0]
            // const sliceSize = [...this.maxCoords.clone().sub(this.minCoords).toArray().toReversed(), 1]
            // const subVolume = this.viewer.tensors.volume.slice(sliceBegin, sliceSize)

            const spacing = this.parameters.volume.spacing.toArray()
            const subVolume = this.viewer.tensors.volume

            const condition = subVolume.greater([this.threshold])

            const occupancy = this.padPow2(condition)
            condition.dispose()

            // compute the occupancy density of each block
            const baseOccumap = tf.maxPool3d(occupancy, [2, 2, 2], [2, 2, 2], 'same')
            occupancy.dispose()

            const [occumaps, lods] = this.generateAtlas(baseOccumap)
            baseOccumap.dispose()
      
            this.occumaps = {
                data          : new Uint8Array(occumaps.dataSync()),
                dimensions    : occumaps.shape.slice(0, 3).toReversed(),
                baseDimensions: baseOccumap.shape.slice(0, 3).toReversed(),
                baseSpacing   : spacing.map((space) => 2 * space),
                baseSize      : occupancy.shape.slice(0, 3).toReversed().map((dim, i) => dim * spacing[i]),
                lods          : lods,
            }
        })

    }

    dataSync()  
    {
        
        if (this.viewer.textures.occumaps) this.viewer.textures.occumaps.dispose()
        this.viewer.textures.occumaps = new THREE.Data3DTexture(this.occumaps.data, ...this.occumaps.dimensions)     
        this.viewer.textures.occumaps.type = THREE.UnsignedByteType
        this.viewer.textures.occumaps.format = THREE.RedFormat
        this.viewer.material.uniforms.u_sampler.value.occumaps = this.viewer.textures.occumaps
        this.viewer.textures.occumaps.needsUpdate = true
        this.viewer.material.needsUpdate = true

        const occumaps = this.viewer.material.uniforms.u_occumaps.value
        occumaps.lods = this.occumaps.lods
        occumaps.dimensions.fromArray(this.occumaps.dimensions)
        occumaps.base_dimensions.fromArray(this.occumaps.baseDimensions)
        occumaps.base_spacing.fromArray(this.occumaps.baseSpacing)
        occumaps.base_size.fromArray(this.occumaps.baseSize)

        console.log(this.occumaps)
        console.log(this.viewer.textures.occumaps)
        console.log(occumaps)
    }

    update()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.minCoords = this.viewer.material.uniforms.u_occupancy.value.min_coords
        this.maxCoords = this.viewer.material.uniforms.u_occupancy.value.max_coords
    }

    destroy()
    {
        this.data           = null
        this.viewer         = null
        this.parameters     = null
        this.threshold      = null
        this.blockDivisions = null
    }

    // helper tensor functions

    padPow2(tensor)
    {
        const nextPowerOf2 = (x) => Math.pow(2, Math.ceil(Math.log2(x)))
        const padShape = tensor.shape.map(nextPowerOf2)
        const padded = tf.pad(tensor, padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
        tensor.dispose()
        return padded
    }

    generateAtlas(tensor)
    {
        let subTensor = tensor
        let atlasTensor = subTensor.pad([[0, subTensor.shape[0] / 2], [0, 0], [0, 0], [0, 0] ])
        let offset = [subTensor.shape[0], 0, 0, 0]
        let lod = 1

        while(Math.min(...subTensor.shape.slice(0, 3)) > 1)
        {
            const subTensorTemp = tf.maxPool3d(subTensor, [2, 2, 2], [2, 2, 2], 'same')            
            subTensor.dispose()
            subTensor = subTensorTemp

            const paddedTensor = subTensor.pad([
                [offset[0], atlasTensor.shape[0] - offset[0] - subTensor.shape[0]],
                [offset[1], atlasTensor.shape[1] - offset[1] - subTensor.shape[1]],
                [offset[2], atlasTensor.shape[2] - offset[2] - subTensor.shape[2]],
                [offset[3], atlasTensor.shape[3] - offset[3] - subTensor.shape[3]],
            ])

            const atlasTensorTemp = atlasTensor.add(paddedTensor)
            paddedTensor.dispose()
            atlasTensor.dispose()
            atlasTensor = atlasTensorTemp

            offset[1] += subTensor.shape[1]
            lod++
        }
        return [atlasTensor, lod]
    }
   
}