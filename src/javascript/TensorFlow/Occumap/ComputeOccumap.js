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
        this.blockDivisions = this.viewer.material.uniforms.u_occupancy.value.block_divisions
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const condition = volume.greater([this.threshold])
            this.blockDims = volume.shape.map((dim) => Math.ceil(dim / this.blockDivisions))
            const occumap = tf.maxPool3d(condition, this.blockDims, this.blockDims, 'same')
            this.mipmaps = this.generateMipmaps(occumap)
        })

        return { mipmaps: this.mipmaps, blockDims: this.blockDims }
    }

    dataSync()
    { 
        if (this.viewer.textures.occumap) 
            this.viewer.textures.occumap.dispose()

        this.viewer.textures.occumap = new THREE.Data3DTexture(
            this.mipmaps[0].data,   
            this.mipmaps[0].width,  
            this.mipmaps[0].height, 
            this.mipmaps[0].depth    
        )       

        this.viewer.textures.occumap.format = THREE.RedFormat
        this.viewer.textures.occumap.type = THREE.UnsignedByteType
        this.viewer.textures.occumap.wrapS = THREE.RepeatWrapping
        this.viewer.textures.occumap.wrapT = THREE.RepeatWrapping
        this.viewer.textures.occumap.wrapR = THREE.RepeatWrapping
        this.viewer.textures.occumap.minFilter = THREE.NearestFilter
        this.viewer.textures.occumap.magFilter = THREE.NearestFilter
        this.viewer.textures.occumap.mipmaps = this.mipmaps
        this.viewer.textures.occumap.generateMipmaps = false
        this.viewer.textures.occumap.needsUpdate = true

        this.viewer.material.uniforms.u_occupancy.value.occumap_dimensions.set(this.mipmaps[0].width, this.mipmaps[0].height, this.mipmaps[0].depth)
        this.viewer.material.uniforms.u_occupancy.value.block_dimensions.set(this.blockDims[2], this.blockDims[1], this.blockDims[0])
        this.viewer.material.uniforms.u_occupancy.value.block_divisions = this.blockDivisions
        this.viewer.material.uniforms.u_sampler.value.occumap = this.viewer.textures.occumap
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.blockDivisions = this.viewer.material.uniforms.u_occupancy.value.block_divisions
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
        const mipmaps = []  // Array to hold mipmaps {data, width, height, depth}
        let currentLevel = occumap
    
        // Generate mipmaps up to maxLevels or until the size becomes 1x1x1
        for (let level = 0; level < maxLevels; level++) 
        {
            // Get the current dimensions (assuming shape is [depth, height, width])
            const [depth, height, width] = currentLevel.shape
    
            // If the smallest dimension is 1, stop further processing
            if (Math.min(depth, height, width) <= 1) break
    
            // Get the raw data (this will depend on the environment, but here's an example for TensorFlow.js)
            const data = Uint8Array.from(currentLevel.dataSync(), value => value * 255);  // converts boolean tensor data to a Uint8Array

            // Add the current level's mipmap as an object
            mipmaps.push({
                data: data,        // Flattened data (Uint8Array)
                width: width,      // Width of the texture
                height: height,    // Height of the texture
                depth: depth       // Depth of the texture
            })
    
            // If this is the last level (no more downsampling), break
            if (level === maxLevels - 1) break
    
            // Downsample the current level using maxPool3d to the next mipmap level
            const nextLevel = tf.maxPool3d(currentLevel.expandDims(0),  [2, 2, 2],  [2, 2, 2], 'same').squeeze(0)                    
    
            // Update current level for the next iteration
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