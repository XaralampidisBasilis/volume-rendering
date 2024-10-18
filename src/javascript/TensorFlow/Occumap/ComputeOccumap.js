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
            const volume = this.viewer.tensors.volume
            const condition = volume.greater([this.threshold])
            const occupancy = this.padPow2(condition)

            const prevPowerOf2 = (x) => Math.pow(2, Math.ceil(Math.log2(x)) - 1)
            const blockDivisions = occupancy.shape.map(prevPowerOf2)
            const blockDims = occupancy.shape.map((dim, i) => Math.ceil(dim / blockDivisions[i]))

            // convert boolean values to uint8
            const occupancy0 = occupancy.mul([255])
            occupancy.dispose()

            // compute the occupancy density of each block
            const occumap0 = tf.avgPool3d(occupancy0, blockDims, blockDims, 'same')
            occupancy0.dispose()
            
            this.mipmaps = this.generateMipmaps(occumap0)
            this.blockDivisions = blockDivisions.toReversed()
            this.blockDims = blockDims.toReversed()
        })

        return { mipmaps: this.mipmaps, blockDims: this.blockDims }
    }

    dataSync()
    { 
        // if (this.viewer.textures.occumap) 
        //     this.viewer.textures.occumap.dispose()

        // this.mipmaps[0].data.fill(255)
   
        this.viewer.textures.occumap = new THREE.Data3DTexture(
            this.mipmaps[0].data,   
            this.mipmaps[0].width,  
            this.mipmaps[0].height, 
            this.mipmaps[0].depth    
        )       

        this.viewer.textures.occumap.format = THREE.RedFormat
        this.viewer.textures.occumap.type = THREE.UnsignedByteType
        this.viewer.textures.occumap.wrapS = THREE.ClampToEdgeWrapping 
        this.viewer.textures.occumap.wrapT = THREE.ClampToEdgeWrapping 
        this.viewer.textures.occumap.wrapR = THREE.ClampToEdgeWrapping 
        this.viewer.textures.occumap.minFilter = THREE.NearestMipmapNearestFilter
        this.viewer.textures.occumap.magFilter = THREE.NearestFilter
        this.viewer.textures.occumap.mipmaps = this.mipmaps
        this.viewer.textures.occumap.generateMipmaps = false
        this.viewer.textures.occumap.needsUpdate = true

        const u_occupancy = this.viewer.material.uniforms.u_occupancy.value
        u_occupancy.block_min_dims.fromArray(this.blockDims)
        u_occupancy.block_min_size.copy(u_occupancy.block_min_dims).multiply(this.parameters.volume.spacing)
        u_occupancy.occumap_num_lod = this.mipmaps.length
        u_occupancy.occumap_max_dims.set(this.mipmaps[0].width, this.mipmaps[0].height, this.mipmaps[0].depth)
        u_occupancy.occumap_size.copy(u_occupancy.occumap_max_dims).multiply(u_occupancy.block_min_size)
        this.viewer.material.uniforms.u_sampler.value.occumap = this.viewer.textures.occumap

        console.log(this.mipmaps)
        console.log(this.viewer.textures.occumap)
        console.log(this.viewer.material.uniforms)
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

    generateMipmaps(occumap) 
    {
        let mipmap = occumap
        let shape = mipmap.shape.slice(0, 3)
        let data = Uint8Array.from(mipmap.dataSync(), (x) => Math.ceil(x)) 

        const mipmaps = [] 
        mipmaps.push({ data: data, width: shape[2], height: shape[1], depth: shape[0] })

        while(Math.max(...shape) > 1)
        {
            const nextMipmap = tf.avgPool3d(mipmap, [2, 2, 2], [2, 2, 2], 'same')            
            mipmap.dispose()
            mipmap = nextMipmap
            data = Uint8Array.from(mipmap.dataSync(), (x) => Math.ceil(x)) 
            shape = mipmap.shape.slice(0, 3)
            mipmaps.push({ data: data, width: shape[2], height: shape[1], depth: shape[0] })
        }

        mipmap.dispose()
        return mipmaps
    }

    splitBlocks(tensor, numBlocks) 
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