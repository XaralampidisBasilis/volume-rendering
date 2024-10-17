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
            // const condition = tf.fill (volume.shape, true,'bool')

            // pad dimensions to the next power of 2
            const paddedDims = condition.shape.map((dim) => Math.pow(2, Math.ceil(Math.log2(dim))))
            const paddedCondition = tf.pad(condition, paddedDims.map((dim, i) => [0, dim - condition.shape[i]]))
            condition.dispose()
            
            const blockDivisions = paddedDims.map((dim) => Math.pow(2, Math.ceil(Math.log2(dim)) - 1))
            const blockDims = paddedDims.map((dim, i) => Math.ceil(dim / blockDivisions[i]))

            // convert boolean values to uint8
            const occupancy = paddedCondition.mul([255])
            paddedCondition.dispose()

            // compute the occupancy density of each block
            const occumap = tf.avgPool3d(occupancy, blockDims, blockDims, 'same')
            occupancy.dispose()
            
            this.mipmaps = this.generateMipmaps(occumap)
            this.blockDivisions = blockDivisions.toReversed()
            this.blockDims = blockDims.toReversed()
        })

        return { mipmaps: this.mipmaps, blockDims: this.blockDims }
    }

    dataSync()
    { 
        // if (this.viewer.textures.occumap) 
        //     this.viewer.textures.occumap.dispose()
   
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
        this.viewer.textures.occumap.minFilter = THREE.NearestFilter
        this.viewer.textures.occumap.magFilter = THREE.NearestFilter
        this.viewer.textures.occumap.mipmaps = this.mipmaps
        this.viewer.textures.occumap.generateMipmaps = false
        this.viewer.textures.occumap.needsUpdate = true

        this.viewer.material.uniforms.u_occupancy.value.block_min_dims.fromArray(this.blockDims)
        this.viewer.material.uniforms.u_occupancy.value.block_min_size.copy(this.viewer.material.uniforms.u_occupancy.value.block_min_dims).multiply(this.parameters.volume.spacing)
        this.viewer.material.uniforms.u_occupancy.value.occumap_num_lod = this.mipmaps.length
        // this.viewer.material.uniforms.u_occupancy.value.occumap_num_lod = Math.floor(Math.log2(Math.max(this.mipmaps[0].width, this.mipmaps[0].height, this.mipmaps[0].depth))) + 1

        this.viewer.material.uniforms.u_occupancy.value.occumap_max_dims.set(this.mipmaps[0].width, this.mipmaps[0].height, this.mipmaps[0].depth)
        this.viewer.material.uniforms.u_occupancy.value.occumap_size.copy(this.viewer.material.uniforms.u_occupancy.value.occumap_max_dims).multiply(this.viewer.material.uniforms.u_occupancy.value.block_min_size)
        this.viewer.material.uniforms.u_sampler.value.occumap = this.viewer.textures.occumap
        this.viewer.material.needsUpdate = true

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

    generateMipmaps(occumap, maxLevels = Infinity) 
    {
        const mipmaps = [] 
        let currentLevel = occumap
    
        for (let level = 0; level < maxLevels; level++) 
        {
            const [depth, height, width] = currentLevel.shape

            if (Math.min(depth, height, width) <= 1) break
            const data = Uint8Array.from(currentLevel.dataSync(), (x) => Math.ceil(x)) 
            mipmaps.push({ data: data, width: width, height: height,  depth: depth  })
    
            if (level === maxLevels - 1) break
            const nextLevel = tf.avgPool3d(currentLevel.expandDims(0),  [2, 2, 2],  [2, 2, 2], 'same').squeeze(0)                    
            currentLevel.dispose()
            currentLevel = nextLevel
        }
    
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