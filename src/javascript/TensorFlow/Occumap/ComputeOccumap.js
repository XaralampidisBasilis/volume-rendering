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
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            const spacing = this.parameters.volume.spacing.toArray()
            const volume = this.viewer.tensors.volume
            const condition = volume.greater([this.threshold])

            const padded = this.padPow2(condition)
            condition.dispose()

            const occupancy = this.quantize(padded)
            padded.dispose()

            // compute the occupancy density of each block
            const baseOccumap = tf.avgPool3d(occupancy, [2, 2, 2], [2, 2, 2], 'same')
            occupancy.dispose()

            const [occumaps, lods] = this.generateAtlas(baseOccumap)
            const dimensions = occumaps.shape.slice(0, 3).toReversed()
            const baseDimensions = baseOccumap.shape.slice(0, 3).toReversed()
            const baseSize = padded.shape.slice(0, 3).toReversed().map((dim, i) => dim * spacing[i])
            const baseSpacing = baseSize.map((size, i) => size / baseDimensions[i])

            this.occumaps = {
                data          : Uint8Array.from(occumaps.dataSync(), (x) => Math.ceil(x)),
                dimensions    : dimensions,
                baseDimensions: baseDimensions,
                baseSpacing   : baseSpacing,
                baseSize      : baseSize,
                lods          : lods,
            }
        })

    }

    dataSync()  
    {
        
        // if (this.viewer.textures.occumaps) this.viewer.textures.occumaps.dispose()
        this.viewer.textures.occumaps = new THREE.Data3DTexture(this.occumaps.data, ...this.occumaps.dimensions)     
        this.viewer.textures.occumaps.type = THREE.UnsignedByteType
        this.viewer.textures.occumaps.format = THREE.RedFormat
        this.viewer.textures.occumaps.wrapS = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.wrapT = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.wrapR = THREE.ClampToEdgeWrapping
        this.viewer.textures.occumaps.minFilter = THREE.NearestFilter
        this.viewer.textures.occumaps.magFilter = THREE.NearestFilter
        this.viewer.textures.occumaps.needsUpdate = true
        this.viewer.material.uniforms.u_sampler.value.occumaps = this.viewer.textures.occumaps
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

    quantize(tensor)
    {
        const scaled = tensor.mul([255])
        tensor.dispose()
        const clipped = scaled.clipByValue(0, 255)  
        scaled.dispose()
        const quantized = clipped.round()
        scaled.dispose()
        return quantized
    }

    generateAtlas(tensor)
    {
        let subTensor = tensor
        let atlasTensor = subTensor.pad([[0, subTensor.shape[0] / 2], [0, 0], [0, 0], [0, 0] ])
        let offset = [subTensor.shape[0], 0, 0, 0]
        let lod = 1

        while(Math.min(...subTensor.shape.slice(0, 3)) > 1)
        {
            const subTensorTemp = tf.avgPool3d(subTensor, [2, 2, 2], [2, 2, 2], 'same')            
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

    generateMipmaps(occumap) 
    {
        let mipmap = occumap
        let shape = mipmap.shape.slice(0, 3)
        let data = Uint8Array.from(mipmap.dataSync(), (x) => Math.ceil(x)) 
        const array = [] 
        array.push({ data: data, width: shape[2], height: shape[1], depth: shape[0]})

        while(Math.min(...shape) > 1)
        {
            const nextMipmap = tf.avgPool3d(mipmap, [2, 2, 2], [2, 2, 2], 'same')            
            mipmap.dispose()
            mipmap = nextMipmap
            data = Uint8Array.from(mipmap.dataSync(), (x) => Math.ceil(x)) 
            shape = mipmap.shape.slice(0, 3)
            array.push({ data: data, width: shape[2], height: shape[1], depth: shape[0]})
        }
        mipmap.dispose()
        return array
    }

    split(tensor, numBlocks) 
    {
        const inputShape = tensor.shape  // Shape of the input tensor [D1, D2, D3]
    
        // Compute block shape by dividing the input shape by the number of blocks
        const blockShape = inputShape.map((dim, i) => Math.ceil(dim / numBlocks[i]))
    
        // Compute padding required for each dimension to ensure the dimensions are divisible by block shape
        const paddingAmount = inputShape.map((dim, i) => {
            const remainder = dim % blockShape[i]
            return (remainder === 0) ? 0 : blockShape[i] - remainder
        })
    
        // Apply padding to the tensor if necessary
        const paddedValue = 0
        const paddedTensor = tf.pad3d(
            tensor,
            [[0, paddingAmount[0]], [0, paddingAmount[1]], [0, paddingAmount[2]]],
            paddedValue  
        )
        tensor.dispose()
        const paddedShape = paddedTensor.shape
    
        // Compute the new shape for reshaping: splitting into block dimensions
        const newShape = [
            paddedShape[0] / blockShape[0], blockShape[0],  // First dimension
            paddedShape[1] / blockShape[1], blockShape[1],  // Second dimension
            paddedShape[2] / blockShape[2], blockShape[2]   // Third dimension
        ]
    
        // Reshape the tensor to isolate the blocks
        const reshapedTensor = paddedTensor.reshape(newShape)
        paddedTensor.dispose()
    
        // Transpose the dimensions to bring the blocks together
        const transposedTensor = reshapedTensor.transpose([0, 2, 4, 1, 3, 5])
        reshapedTensor.dispose()

        // Finally, reshape into (numBlocks, blockShape[0], blockShape[1], blockShape[2])
        const blockTensor = transposedTensor.reshape([
            newShape[0] * newShape[2] * newShape[4],  // Number of blocks (batch size)
            blockShape[0], blockShape[1], blockShape[2]  // Each block's size
        ])
        transposedTensor.dispose()
    
        return [blockTensor, blockShape]
    }

   
}