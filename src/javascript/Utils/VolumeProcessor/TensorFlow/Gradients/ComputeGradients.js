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
        this.method = this.viewer.material.defines.VOLUME_GRADIENTS_METHOD
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
        console.time('computeGradients')
        tf.tidy(() => 
        {
            const volume = this.viewer.tensors.volume
            const spacing = this.parameters.volume.spacing

            // compute gradients
            const [gradientX, minGradX, maxGradX] = this.gradient(volume, this.filter.kernelX, spacing.x)
            const [gradientY, minGradY, maxGradY] = this.gradient(volume, this.filter.kernelY, spacing.y)
            const [gradientZ, minGradZ, maxGradZ] = this.gradient(volume, this.filter.kernelZ, spacing.z)

            // extract the tensor data as an array of uint8
            this.gradX = new Uint8Array(gradientX.dataSync())
            gradientX.dispose()

            this.gradY = new Uint8Array(gradientY.dataSync())
            gradientY.dispose()

            this.gradZ = new Uint8Array(gradientZ.dataSync())
            gradientZ.dispose()

            // combine bounds
            const minGrad = tf.stack([minGradX, minGradY, minGradZ], 0) 
            tf.dispose([minGradX, minGradY, minGradZ])
            
            const maxGrad = tf.stack([maxGradX, maxGradY, maxGradZ], 0)
            tf.dispose([maxGradX, maxGradY, maxGradZ])

            // extract bounds as three vector3
            this.minGrad = new THREE.Vector3().fromArray(minGrad.arraySync())
            minGrad.dispose()

            this.maxGrad = new THREE.Vector3().fromArray(maxGrad.arraySync())
            maxGrad.dispose()

            this.maxNorm = Math.max(this.minGrad.length(), this.maxGrad.length())
        })
        console.timeEnd('computeGradients')
    }

    dataSync()
    {
        for (let i = 0; i < this.parameters.volume.count; i++) 
        {
            const i4 = i * 4
            this.viewer.data.volume[i4 + 1] = this.gradX[i]
            this.viewer.data.volume[i4 + 2] = this.gradY[i]
            this.viewer.data.volume[i4 + 3] = this.gradZ[i]
        }
        
        this.viewer.textures.volume.needsUpdate = true
        this.viewer.material.uniforms.u_volume.value.min_gradient = this.minGrad
        this.viewer.material.uniforms.u_volume.value.max_gradient = this.maxGrad
        this.viewer.material.uniforms.u_volume.value.max_gradient_length = this.maxNorm
        this.viewer.material.needsUpdate = true
    }

    update()
    {
        this.dispose()
        this.method = this.viewer.material.defines.VOLUME_GRADIENTS_METHOD
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
        this.gradX = null
        this.gradY = null
        this.gradZ = null
        this.minGrad = null
        this.maxGrad = null
        this.maxNorm = null
    }

    // helper tensor functions

    gradient(tensor, kernel, spacing)
    {
        const gradient = this.convolute(tensor, kernel, spacing)
        const [min, max] = this.rangeFast(gradient)

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
        const k = Math.floor(array.size * (1 - percentage / 100))
        const topK = tf.topk(array, k, true) 
        array.dispose() 
        const percentile = topK.values.min() 
        topK.values.dispose() 
        topK.indices.dispose()
        return percentile
    }

    range(tensor)
    {
        return [tensor.min(), tensor.max()]
    }

    rangeRobust(tensor)
    {
        const percentage = 99.9
        const arrayMax = tensor.reshape([-1])
        const arrayMin = arrayMax.mul([-1])
        const k = Math.floor(arrayMax.size * (1 - percentage / 100))

        const maxK = tf.topk(arrayMax, k, true) 
        const max = maxK.values.min()
        maxK.values.dispose() 
        maxK.indices.dispose()
        arrayMax.dispose()

        const minK = tf.topk(arrayMin, k, true) 
        const min = minK.values.min().mul([-1])
        minK.values.dispose() 
        minK.indices.dispose()
        arrayMin.dispose() 

        return [min, max]    
    }

    rangeFast(tensor)
    {
        const percentile = 99.9
        const sampleRate = 0.01

        const array = tensor.reshape([-1])
        const sampleSize = Math.max(1, Math.floor(array.size * sampleRate))
        const indices = tf.randomUniform([sampleSize], 0, array.size, 'int32')
        const subArray = tf.gather(array, indices)
        array.dispose()

        const negArray = subArray.mul([-1])
        const k = Math.floor(subArray.size * (1 - percentile / 100))

        const topK = tf.topk(subArray, k, true) 
        const max = topK.values.min()   
        subArray.dispose()

        const botK = tf.topk(negArray, k, true) 
        const min = botK.values.min().mul([-1])
        negArray.dispose() 

        tf.dispose([botK, topK]) 
 
        return [min, max]    
    }

}