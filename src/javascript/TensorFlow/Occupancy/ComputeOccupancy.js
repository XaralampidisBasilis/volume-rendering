import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

// assumes intensity data 3D, and data3DTexture
export default class ComputeOccupancy
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            const spacing = [...this.parameters.volume.spacing.toArray().toReversed(), 1]
            const condition = this.viewer.tensors.volume.greater([this.threshold])

            const [minCoords, maxCoords] = this.argRange4d(condition)
            const [minPosition, maxPosition] = [minCoords.mul(spacing), maxCoords.mul(spacing)]

            const occupancy = this.padPow2(condition)
            condition.dispose()

            // compute the occupancy density of each block
            const baseOccumap = tf.maxPool3d(occupancy, [2, 2, 2], [2, 2, 2], 'same')
            occupancy.dispose()
            
            const [occumapAtlasLod, lods] = this.buildAtlasLod(baseOccumap)
            baseOccumap.dispose()
      
            this.results = {
                data          : new Uint8Array(occumapAtlasLod.dataSync()),
                dimensions    : occumapAtlasLod.shape.slice(0, 3).toReversed(),
                lods          : lods,
                baseSpacing   : spacing.map((space) => 2 * space).slice(0, 3).toReversed(),
                baseDimensions: baseOccumap.shape.slice(0, 3).toReversed(),
                baseSize      : occupancy.shape.map((dim, i) => dim * spacing[i]).slice(0, 3).toReversed(),
                minCoords     : minCoords.arraySync().slice(0, 3).toReversed(),
                maxCoords     : maxCoords.arraySync().slice(0, 3).toReversed(),
                minPosition   : minPosition.arraySync().slice(0, 3).toReversed(),
                maxPosition   : maxPosition.arraySync().slice(0, 3).toReversed(),
            }
        })

        return { results: this.results }
    }

    dataSync()  
    {
        if (this.viewer.textures.occumaps) 
            this.viewer.textures.occumaps.dispose()
        this.viewer.textures.occumaps = new THREE.Data3DTexture(this.results.data, ...this.results.dimensions)     
        this.viewer.textures.occumaps.type = THREE.UnsignedByteType
        this.viewer.textures.occumaps.format = THREE.RedFormat
        this.viewer.textures.occumaps.wrapS = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.wrapT = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.wrapR = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.minFilter = THREE.LinearFilter
        this.viewer.textures.occumaps.magFilter = THREE.LinearFilter
        this.viewer.textures.occumaps.needsUpdate = true

        this.viewer.material.uniforms.u_occupancy.value.lods = this.results.lods
        this.viewer.material.uniforms.u_occupancy.value.dimensions.fromArray(this.results.dimensions)
        this.viewer.material.uniforms.u_occupancy.value.base_dimensions.fromArray(this.results.baseDimensions)
        this.viewer.material.uniforms.u_occupancy.value.base_spacing.fromArray(this.results.baseSpacing)
        this.viewer.material.uniforms.u_occupancy.value.base_size.fromArray(this.results.baseSize)
        this.viewer.material.uniforms.u_occupancy.value.min_coords.fromArray(this.results.minCoords)
        this.viewer.material.uniforms.u_occupancy.value.max_coords.fromArray(this.results.maxCoords)
        this.viewer.material.uniforms.u_occupancy.value.min_position.fromArray(this.results.minPosition)
        this.viewer.material.uniforms.u_occupancy.value.max_position.fromArray(this.results.maxPosition)
        this.viewer.material.uniforms.u_sampler.value.occumaps = this.viewer.textures.occumaps
        this.viewer.material.needsUpdate = true

        this.results.data = null
    }

    update()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
    }

    destroy() 
    {
        this.data = null;
        this.results = null;
        this.viewer = null;
        this.parameters = null;
        this.threshold = null;
        this.blockDivisions = null;

        console.log('ComputeOccupancy destroyed and resources freed.');
    }

    // helper tensor functions

    argRange(tensor, axis)
    // Computes the range of indices along a specific axis 
    // where the tensor has non-zero values [minInd, maxInd)
    {
        const axes = [0, 1, 2, 3].toSpliced(axis, 1)
        const dimension = tensor.shape[axis]
        const condition = tensor.any(axes)
        const minInd = condition.argMax(0)
        const maxInd = tf.sub(dimension, condition.reverse().argMax(0))
        condition.dispose()
        return [minInd, maxInd] 
    }

    argRange4d(tensor)
    // Computes the range of indices along all 4 axis
    // where the tensor has non-zero values [minInd, maxInd)
    {
        const [minInd0, maxInd0] = this.argRange(tensor, 0)
        const [minInd1, maxInd1] = this.argRange(tensor, 1)
        const [minInd2, maxInd2] = this.argRange(tensor, 2)
        const [minInd3, maxInd3] = this.argRange(tensor, 3)
        const minCoords = tf.stack([minInd0, minInd1, minInd2, minInd3], 0)    
        const maxCoords = tf.stack([maxInd0, maxInd1, maxInd2, maxInd3], 0) 
        tf.dispose([minInd0, minInd1, minInd2, minInd3])
        tf.dispose([maxInd0, maxInd1, maxInd2, maxInd3])
        return [minCoords, maxCoords]
    }
    
    padPow2(tensor)
    {
        const nextPowerOf2 = (x) => Math.pow(2, Math.ceil(Math.log2(x)))
        const padShape = tensor.shape.map(nextPowerOf2)
        const padded = tf.pad(tensor, padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
        tensor.dispose()
        return padded
    }

    buildAtlasLod(tensor)
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