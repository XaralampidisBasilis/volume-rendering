import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Scharr from './Filters/Scharr'
import Sobel from './Filters/Sobel'
import Prewitt from './Filters/Prewitt'
import Tetrahedron from './Filters/Tetrahedron'
import Central from './Filters/Central'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradients
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters
        this.method = this.viewer.material.defines.GRADIENT_METHOD
        this.filter = this.select()
    }
   
    select() {

        switch (this.method) 
        {
            case 1: return new Scharr()
            case 2: return new Sobel()
            case 3: return new Prewitt()
            case 4: return new Tetrahedron()
            case 5: return new Central()
            default: throw new Error(`unknown gradient method: ${this.method}`)
        }
    }
    
    async compute() 
    {
        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const spacing = this.parameters.volume.spacing

            // compute gradients
            const [gradientX, minX, maxX] = this.gradient(volume, this.filter.kernelX, spacing.x)
            const [gradientY, minY, maxY] = this.gradient(volume, this.filter.kernelY, spacing.y)
            const [gradientZ, minZ, maxZ] = this.gradient(volume, this.filter.kernelZ, spacing.z)

            // extract the tensor data as an array of uint8
            this.dataX = new Uint8Array(gradientX.dataSync())
            gradientX.dispose()

            this.dataY = new Uint8Array(gradientY.dataSync())
            gradientY.dispose()

            this.dataZ = new Uint8Array(gradientZ.dataSync())
            gradientZ.dispose()

            // combine bounds
            const minGrad = tf.stack([minX, minY, minZ], 0) 
            tf.dispose([minX, minY, minZ])
            
            const maxGrad = tf.stack([maxX, maxY, maxZ], 0)
            tf.dispose([maxX, maxY, maxZ])

            // extract bounds as three vector3
            this.min = new THREE.Vector3().fromArray(minGrad.arraySync())
            minGrad.dispose()

            this.max = new THREE.Vector3().fromArray(maxGrad.arraySync())
            maxGrad.dispose()

            this.maxNorm = Math.max(this.min.length(), this.max.length())
        })

        return { dataX: this.dataX, dataY: this.dataY, dataZ: this.dataZ, maxNorm: this.maxNorm, min: this.min, max: this.max } 
    }

    async compute2() 
    {
        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const spacing = this.parameters.volume.spacing

            // compute gradients
            const gradientX = this.convolute(volume, this.filter.kernelX, spacing.x)
            const gradientY = this.convolute(volume, this.filter.kernelY, spacing.y)
            const gradientZ = this.convolute(volume, this.filter.kernelZ, spacing.z)

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

        return { data: this.data, maxNorm: this.maxNorm } 
    }

    dataSync()
    {
        for (let i = 0; i < this.parameters.volume.count; i++) 
        {
            const i4 = i * 4
            this.viewer.data.volume[i4 + 1] = this.dataX[i]
            this.viewer.data.volume[i4 + 2] = this.dataY[i]
            this.viewer.data.volume[i4 + 3] = this.dataZ[i]
        }
        
        this.viewer.textures.volume.needsUpdate = true
        this.viewer.material.uniforms.u_gradient.value.min = this.min
        this.viewer.material.uniforms.u_gradient.value.max = this.max
        this.viewer.material.uniforms.u_gradient.value.max_norm = this.maxNorm
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.dispose()
        this.method = this.viewer.material.defines.GRADIENT_METHOD
        this.filter = this.select()
    }
 
    dispose()
    {
        if (this.filter)
            this.filter.dispose()
    }

    destroy()
    {
        this.dispose()
        this.filter = null
        this.dataX = null
        this.dataY = null
        this.dataZ = null
        this.min = null
        this.max = null
        this.maxNorm = null
    }

    // helper tensor functions

    gradient(tensor, kernel, spacing)
    {
        const gradient = this.convolute(tensor, kernel, spacing)
        const [min, max] = [gradient.min(), gradient.max()]

        const normalized = this.normalize(gradient, min, max)
        const quantized = this.quantize(normalized)

        return [quantized, min, max]
    }

    convolute(tensor, kernel, spacing)
    {
        if (kernel.isSeparable) {
            const passX = tf.conv3d(tensor, kernel.separableX, 1, 'same')
            const passY = tf.conv3d(passX, kernel.separableY, 1, 'same') 
            passX.dispose()
            const passZ = tf.conv3d(passY, kernel.separableZ, 1, 'same') 
            passY.dispose()
            const gradient = passZ.div([spacing])
            passZ.dispose()
            return gradient
        } else {
            const pass = tf.conv3d(tensor, kernel, 1, 'same')
            const gradient = pass.div([spacing])
            pass.dispose()
            return gradient
        }
    }

    normalize(tensor, min, max)
    {
        const shifted = tensor.sub(min)
        tensor.dispose()
        const normalized = shifted.div(tf.sub(max, min))
        shifted.dispose()
        return normalized
    }

    quantize(tensor)
    {
        const scaled = tensor.mul([255])
        tensor.dispose()
        const clipped = scaled.clipByValue(0, 255)  
        scaled.dispose()
        const quantized = clipped.round()
        clipped.dispose()
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