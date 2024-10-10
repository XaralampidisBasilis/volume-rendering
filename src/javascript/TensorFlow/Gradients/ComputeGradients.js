import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Scharr from './Kernels/Scharr'
import Sobel from './Kernels/Sobel'
import Prewitt from './Kernels/Prewitt'
import Tetrahedron from './Kernels/Tetrahedron'
import Central from './Kernels/Central'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradients
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.method = this.viewer.material.defines.GRADIENT_METHOD
        this.kernels = new Sobel()
    }

    generate() {

        switch (this.method) 
        {
            case 1: return new Scharr()
            case 2: return new Sobel()
            case 3: return new Prewitt()
            case 4: return new Tetrahedron()
            case 5: return new Central()
            default: 
                throw new Error(`Unknown GRADIENT_METHOD: ${this.method}`)
        }
    }
    

    async compute() 
    {
        console.time('computeGradients')

        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const spacing = this.parameters.volume.spacing

            // compute gradients
            const gradientX = this.convolute(volume, this.kernels.x, spacing.x)
            const gradientY = this.convolute(volume, this.kernels.y, spacing.y)
            const gradientZ = this.convolute(volume, this.kernels.z, spacing.z)

            // compute bounds 
            const [minX, maxX] = [gradientX.min(), gradientX.max()]
            const [minY, maxY] = [gradientY.min(), gradientY.max()]
            const [minZ, maxZ] = [gradientZ.min(), gradientZ.max()]

            // normalize gradients in range [0, 1]
            const normalizedX = this.normalize(gradientX, minX, maxX)
            const normalizedY = this.normalize(gradientY, minY, maxY)
            const normalizedZ = this.normalize(gradientZ, minZ, maxZ)

            // concatenate normalized gradients
            const normalized = tf.concat([normalizedX, normalizedY, normalizedZ], 3)
            normalizedX.dispose()
            normalizedY.dispose()
            normalizedZ.dispose() 

            // quantize normalized gradients
            const quantized = this.quantize(normalized)

            // extract the tensor data as an array of uint8
            this.data = new Uint8Array(quantized.dataSync())
            quantized.dispose()

            // combine bounds
            const min = tf.stack([minX, minY, minZ], 0)    
            const max = tf.stack([maxX, maxY, maxZ], 0)

            // extract bounds as three vector3
            this.min = new THREE.Vector3().fromArray(min.arraySync())
            this.max = new THREE.Vector3().fromArray(max.arraySync())
            this.maxNorm = Math.max(this.min.length(), this.max.length())
        })

        console.log([this.min, this.max, this.maxNorm])
        console.timeEnd('computeGradients')

        return { data: this.data, maxNorm: this.maxNorm, min: this.min, max: this.max } 
    }

    async compute2() 
    {
        console.time('computeGradients')

        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const spacing = this.parameters.volume.spacing

            // compute gradients
            const gradientX = this.convolute(volume, this.kernels.x, spacing.x)
            const gradientY = this.convolute(volume, this.kernels.y, spacing.y)
            const gradientZ = this.convolute(volume, this.kernels.z, spacing.z)

            // concatenate normalized gradients
            const gradients = tf.concat([gradientX, gradientY, gradientZ], 3)
            gradientX.dispose()
            gradientY.dispose()
            gradientZ.dispose() 

            // normalize gradients based on max norm
            const gradientsNorm = tf.norm(gradients, 'euclidean', 3)
            const maxNorm = this.percentile(gradientsNorm, 99.9)

            const scaled = gradients.div(maxNorm)
            gradients.dispose()

            const shifted = scaled.add([1])
            scaled.dispose()

            const normalized = shifted.mul([255 / 2])
            shifted.dispose()

            // quantize normalized gradients
            const quantized = this.quantize(normalized)
            normalized.dispose()

            // extract the tensor data as an array of uint8
            this.data = new Uint8Array(quantized.dataSync())
            quantized.dispose()

            // extract max norm
            this.maxNorm = maxNorm.arraySync()
        })

        console.timeEnd('computeGradients')

        return { data: this.data, maxNorm: this.maxNorm } 
    }

    restart()
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.method = this.viewer.material.defines.GRADIENT_METHOD
        this.kernels = this.generate()
    }

    update()
    {
        for (let i = 0; i < this.parameters.volume.count; i++) 
        {
            const i3 = i * 3
            const i4 = i * 4
            this.viewer.data.volume[i4 + 1] = this.data[i3 + 0]
            this.viewer.data.volume[i4 + 2] = this.data[i3 + 1]
            this.viewer.data.volume[i4 + 3] = this.data[i3 + 2]
        }

        this.viewer.material.uniforms.u_gradient.value.min = this.min
        this.viewer.material.uniforms.u_gradient.value.max = this.max
        this.viewer.material.uniforms.u_gradient.value.max_norm = this.maxNorm
        this.viewer.textures.volume.needsUpdate = true
    }
    
    dispose()
    {
        this.kernels.dispose()
        this.data = null
        this.maxNorm = null
        this.viewer = null
        this.parameters = null
        this.method = null
        console.log(tf.memory())
    }

    // helper tensor functions

    convolute(volume, kernel, spacing)
    {
        const passX = tf.conv3d(volume, kernel.separable.x, 1, 'same')
        const passY = tf.conv3d(passX, kernel.separable.y, 1, 'same') 
        passX.dispose()
        const passZ = tf.conv3d(passY, kernel.separable.z, 1, 'same') 
        passY.dispose()
        const gradient = passZ.div([spacing])
        passZ.dispose()
        return gradient
    }

    normalize(gradient, min, max)
    {
        const shifted = gradient.sub(min)
        gradient.dispose()
        const normalized = shifted.div(tf.sub(max, min))
        shifted.dispose()
        return normalized
    }

    quantize(normalized)
    {
        const scaled = normalized.mul([255])
        normalized.dispose()
        const clipped = scaled.clipByValue(0, 255)  
        scaled.dispose()
        const quantized = clipped.round()
        scaled.dispose()
        return quantized
    }

    percentile(tensor, percentage)
    {
        const array = tensor.reshape([-1])
        tensor.dispose()
        const k = Math.floor(array.size * (1 - percentage / 100))
        const topK = tf.topk(array, k, true) 
        array.dispose() 
        const percentile = topK.values.min() 
        topK.values.dispose() 
        topK.indices.dispose()
        return percentile
    }

}