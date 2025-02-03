import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'

const timeit = (name, callback) => 
{ 
    console.time(name) 
    callback()
    console.timeEnd(name) 
}

export default class MIPProcessor extends EventEmitter
{
    constructor(volume)
    {
        super()

        this.setComputes()
        this.setVolume(volume)
        this.setTensorflow()
    }

    async setTensorflow()
    {
        tf.enableProdMode()
        await tf.setBackend('webgl')
        await tf.ready()
        this.trigger('ready')
    }

    setComputes()
    {
        this.computes = 
        {
            intensityMap: { parameters: null, tensor: null},
            maximaMap   : { parameters: null, tensor: null},
        }

    }

    setVolume(volume)
    {
        timeit('setVolume', () =>
        {
            this.volume = volume
            this.volume.data = new Float32Array(volume.data)
    
            const data = this.volume.data
            const min = this.volume.min
            const scale = 1 / (this.volume.max - this.volume.min)
            for (let i = 0; i < data.length; i++) 
            {
                data[i] = (data[i] - min) * scale;
            }
    
            this.volume.parameters = 
            {
                dimensions       : new THREE.Vector3().fromArray(this.volume.dimensions),
                spacing          : new THREE.Vector3().fromArray(this.volume.spacing),
                size             : new THREE.Vector3().fromArray(this.volume.size),
                spacingLength    : new THREE.Vector3().fromArray(this.volume.spacing).length(),
                sizeLength       : new THREE.Vector3().fromArray(this.volume.size).length(),
                invDimensions    : new THREE.Vector3().fromArray(this.volume.dimensions.map(x => 1/x)),
                invSpacing       : new THREE.Vector3().fromArray(this.volume.spacing.map(x => 1/x)),
                invSize          : new THREE.Vector3().fromArray(this.volume.size.map(x => 1/x)),
                numVoxels        : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
                shape            : this.volume.dimensions.toReversed().concat(1),
                minIntensity     : this.volume.min,
                maxIntensity     : this.volume.max,
            }
        })
    }

    destroy() 
    {
        for (const key of Object.keys(this.computes)) 
        {
            const computes = this.computes[key]
            if (!computes) continue

            if (computes.tensor instanceof tf.Tensor) 
            {
                tf.dispose(computes.tensor)
                computes.tensor = null
            }

            computes.parameters = null
            this.computes[key] = null
        }

        this.computes = null
        this.volume.data = null
        this.volume.parameters = null
        this.volume = null

        console.log('MIPProcessor destroyed.')
    }
      
    //  Computes

    async computeIntensityMap()
    {
        if (this.computes.intensityMap.tensor instanceof tf.Tensor) 
        {
            tf.dispose(this.computes.intensityMap.tensor)
        }

        timeit('computeIntensityMap', () =>
        {
            this.computes.intensityMap.tensor = tf.tensor4d(this.volume.data, this.volume.parameters.shape,'float32')                
            this.computes.intensityMap.parameters = {...this.volume.parameters}
        })

        console.log(this.computes.intensityMap.parameters, this.computes.intensityMap.tensor.dataSync())
    }

    async computeMaximaMap(subDivision)
    {
        if (!(this.computes.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeMaximaMap: intensityMap is not computed`)
        }

        if (this.computes.maximaMap.tensor instanceof tf.Tensor) 
        {
            tf.dispose(this.computes.maximaMap.tensor)
        }

        timeit('computeMaximaMap', () =>
        {
            const maximaMap = this._computeMaximaMap(this.computes.intensityMap.tensor, subDivision)
            const parameters = {}

            parameters.shape = maximaMap.shape
            parameters.subDivision = subDivision
            parameters.invSubDivision = 1/subDivision
            parameters.dimensions = new THREE.Vector3().fromArray(maximaMap.shape.slice(0, 3).toReversed())
            parameters.spacing = new THREE.Vector3().copy(this.volume.parameters.spacing).multiplyScalar(subDivision)
            parameters.size = new THREE.Vector3().copy(parameters.dimensions).multiply(parameters.spacing)
            parameters.numBlocks = parameters.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
            parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
            parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))

            this.computes.maximaMap.tensor = maximaMap
            this.computes.maximaMap.parameters = parameters
        })

        console.log(this.computes.maximaMap.parameters, this.computes.maximaMap.tensor.dataSync())
    }
    
    // Helpers
    
    _computeMinimaMap(tensor4d, subDivision)
    {
        return tf.tidy(() =>
        {
            // Symmetric padding to compute dual map
            const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')
    
            // Min pooling for a dual cell
            const minimaMap = minPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
            tensorPadded.dispose()
    
            // Calculate necessary padding for valid subdivisions
            const padAmounts = minimaMap.shape.map((dim, i) => {
                const paddedDim = (i < 3) ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
                return [0, paddedDim - dim]
            })
        
            // Apply padding
            const minimaMapPadded = tf.pad(minimaMap, padAmounts)
            minimaMap.dispose()
    
            // Apply max pooling with valid padding and subdivision
            const subDivisions = [subDivision, subDivision, subDivision]
            const minimaMinimap = minPool3d(minimaMapPadded, subDivisions, subDivisions, 'valid')
            minimaMapPadded.dispose()
    
            return minimaMinimap
        })
    }

    _computeMaximaMap(tensor4d, subDivision)
    {
        return tf.tidy(() =>
        {
            // Symmetric padding to compute dual map
            const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')
    
            // Min pooling for a dual cell
            const maximaMap = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
            tensorPadded.dispose()
          
            // Calculate necessary padding for valid subdivisions
            const padAmounts = maximaMap.shape.map((dim, i) => {
                const paddedDim = (i < 3) ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
                return [0, paddedDim - dim]
            })
        
            // Apply padding
            const maximaMapPadded = tf.pad(maximaMap, padAmounts)
            maximaMap.dispose()
    
            // Apply max pooling with valid padding and subdivision
            const subDivisions = [subDivision, subDivision, subDivision]
            const maximaMinimap = tf.maxPool3d(maximaMapPadded, subDivisions, subDivisions, 'valid')
            maximaMapPadded.dispose()
    
            return maximaMinimap
        })
    }

    _computeExtremaMap(tensor4d, subDivision)
    {
        return tf.tidy(() =>
        {
            // Symmetric padding to compute dual map
            const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')
    
            // Min/Max pooling for dual voxel
            const minima = this._minPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
            const maxima = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
            tf.dispose(tensorPadded)
    
            // Calculate necessary padding for valid subdivisions
            const subDivisions = [subDivision, subDivision, subDivision]
            const padAmounts = minima.shape.map((dim, i) => 
            {
                const paddedDim = (i < 3) ? subDivision * Math.ceil(dim / subDivision) : dim // Only pad spatial dimensions
                return [0, paddedDim - dim]
            })
        
            // Apply padding
            const minimaPadded = tf.pad(minima, padAmounts)
            tf.dispose(minima)

            // Apply padding
            const maximaPadded = tf.pad(maxima, padAmounts)
            tf.dispose(maxima)
    
            // Apply min pooling with valid padding and subdivision
            const minimaMap = this._minPool3d(minimaPadded, subDivisions, subDivisions, 'valid')
            tf.dispose(minimaPadded)

            // Apply max pooling with valid padding and subdivision
            const maximaMap = maxPool3d(maximaPadded, subDivisions, subDivisions, 'valid')
            tf.dispose(maximaPadded)

            // combine min max maps
            const extremaMap = tf.concat([minimaMap, maximaMap], 3)            
            tf.dispose([minimaMap, maximaMap])
    
            return extremaMap
        })
    }
    
    _minPool3d(tensor4d, filterSize, strides, pad)
    {
        const scalarNegativeOne = tf.scalar(-1, 'float32')
        const negative = tensor4d.mul(scalarNegativeOne)
        const negMaxPool = tf.maxPool3d(negative, filterSize, strides, pad)
        tf.dispose(negative)
        const tensorMinPool = negMaxPool.mul(scalarNegativeOne)
        tf.dispose(negMaxPool)
        tf.dispose(scalarNegativeOne)
        return tensorMinPool
    } 

    _quantize(tensor4d) 
    {
        return tf.tidy(() => 
        {
            // Tensor must be normalized in [0, 1]
            // Scale to the specified quantization levels
            const scaled = tensor4d.mul(tf.scalar(255))
            tf.dispose(tensor4d)
    
            // Clip values to the range [0, levels]
            const clipped = scaled.clipByValue(0, 255)
            tf.dispose(scaled)
    
            // Round and cast to integer type
            const rounded = clipped.round()
            tf.dispose(clipped)
            const quantized = rounded.cast('int32')
            tf.dispose(rounded)
    
            // Return the quantized tensor
            return quantized
        })
    }

}