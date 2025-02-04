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
            extremaMap  : { parameters: null, tensor: null},
            distanceMap : { parameters: null, tensor: null},
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

    async generateIntensityMap()
    {
     
        const intensityMap = tf.tensor4d(this.volume.data, this.volume.parameters.shape,'float32')        
        const parameters = {...this.volume.parameters}
        
        parameters.maxCellCount = parameters.dimensions.clone().addScalar(1).toArray().reduce((intersections, cells) => intersections + cells, -2)

        this.computes.intensityMap.tensor = intensityMap
        this.computes.intensityMap.parameters = parameters

        // console.log(this.computes.intensityMap.parameters, this.computes.intensityMap.tensor.dataSync())
    }

    async generateMaximaMap(subDivision)
    {
        if (!(this.computes.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeMaximaMap: intensityMap is not computed`)
        }
     
        const maximaMap = await this.computeMaximaMap(this.computes.intensityMap.tensor, subDivision)
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
        parameters.maxBlockCount = parameters.dimensions.toArray().reduce((intersections, blocks) => intersections + blocks, -2)

        this.computes.maximaMap.tensor = maximaMap
        this.computes.maximaMap.parameters = parameters
    

        // console.log(this.computes.maximaMap.parameters, this.computes.maximaMap.tensor.dataSync())
    }

    async generateExtremaMap(subDivision)
    {
        if (!(this.computes.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeExtremaMap: intensityMap is not computed`)
        }

        if (this.computes.extremaMap.tensor instanceof tf.Tensor) 
        {
            tf.dispose(this.computes.extremaMap.tensor)
        }

        timeit('computeExtremaMap', () =>
        {
            const extremaMap = this.computeExtremaMap(this.computes.intensityMap.tensor, subDivision)
            const parameters = {}

            parameters.shape = extremaMap.shape
            parameters.subDivision = subDivision
            parameters.invSubDivision = 1/subDivision
            parameters.dimensions = new THREE.Vector3().fromArray(extremaMap.shape.slice(0, 3).toReversed())
            parameters.spacing = new THREE.Vector3().copy(this.volume.parameters.spacing).multiplyScalar(subDivision)
            parameters.size = new THREE.Vector3().copy(parameters.dimensions).multiply(parameters.spacing)
            parameters.numBlocks = parameters.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
            parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
            parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
            parameters.maxBlockCount = parameters.dimensions.toArray().reduce((intersections, blocks) => intersections + blocks, -2)

            this.computes.extremaMap.tensor = extremaMap
            this.computes.extremaMap.parameters = parameters
        })

        // console.log(this.computes.extremaMap.parameters, this.computes.extremaMap.tensor.dataSync())
    }
    
    async generateDistanceMap(maxIters)
    {
        if (!(this.computes.maximaMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeDistanceMap: maximaMap is not computed`)
        }

        const distanceMap = await this.computeDistanceMap(this.computes.maximaMap.tensor, maxIters)
        const parameters = {...this.computes.maximaMap.parameters}
        const maxDistance = distanceMap.max()
        const meanDistance = distanceMap.mean()

        parameters.maxDistance = maxDistance.arraySync()  
        parameters.meanDistance = meanDistance.arraySync()  
        tf.dispose([maxDistance, meanDistance])
        
        this.computes.distanceMap.tensor = distanceMap
        this.computes.distanceMap.parameters = parameters
        
        // console.log(this.computes.distanceMap.parameters, this.computes.distanceMap.tensor.dataSync())
    }
    
    // Helpers
    
    async computeMinimaMap(tensor4d, subDivision)
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

    async computeMaximaMap(tensor4d, subDivision)
    {
        // Symmetric padding to compute dual map
        const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')

        // Min pooling for a dual cell
        const maximaMap = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        tf.dispose(tensorPadded)
        await tf.nextFrame()
        
        // Calculate necessary padding for valid subdivisions
        const padAmounts = maximaMap.shape.map((dim, i) => 
        {
            const paddedDim = (i < 3) ? subDivision * Math.ceil(dim / subDivision) : dim // Only pad spatial dimensions
            return [0, paddedDim - dim]
        })
    
        // Apply padding
        const maximaMapPadded = tf.pad(maximaMap, padAmounts)
        tf.dispose(maximaMap)
        await tf.nextFrame()
        
        // Apply max pooling with valid padding and subdivision
        const subDivisions = [subDivision, subDivision, subDivision]
        const maximaMinimap = tf.maxPool3d(maximaMapPadded, subDivisions, subDivisions, 'valid')
        tf.dispose(maximaMapPadded)
        await tf.nextFrame()

        return maximaMinimap
        
    }

    async computeExtremaMap(tensor4d, subDivision)
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

    async computeDistanceMap(maximaMap, maxIterations) 
    {
        // Initialize next/previous diffusion
        let diffusionPrev = maximaMap.clone()
        let diffusionNext = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')

        // Initialize distance map 
        let distanceMap = tf.zeros(maximaMap.shape, 'int32')

        for (let i = 1; i <= maxIterations; i++) 
        {
            // Compute distance update
            const scalarDistance = tf.scalar(i, 'int32')
            const updateDistance = tf.greaterEqual(maximaMap, diffusionNext)

            // Update distance map
            const distanceMapTemp = this._mix(distanceMap, scalarDistance, updateDistance)
            tf.dispose([distanceMap, updateDistance, scalarDistance])
            distanceMap = distanceMapTemp

            // Update previous diffusion 
            tf.dispose(diffusionPrev)
            diffusionPrev = diffusionNext.clone()

            // Compute next diffusion with max pooling
            tf.dispose(diffusionNext)
            diffusionNext = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }
        
        // Allow for garbage collection 
        tf.dispose([diffusionPrev, diffusionNext])
        await tf.nextFrame()

        // Return the final distance map
        return distanceMap
    }
    
    _minPool3d(tensor4d, filterSize, strides, pad)
    {
        const scalarNegativeOne = tf.scalar(-1, 'float32')
        const negative = tensor4d.mul(scalarNegativeOne)
        const negMaxPool = tf.maxPool3d(negative, filterSize, strides, pad)
        tf.dispose(negative)
        const tensorMinPool = negMaxPool.mul(scalarNegativeOne)
        tf.dispose([negMaxPool, scalarNegativeOne])
        return tensorMinPool
    } 

    _mix(A, B, T)
    {
        const D = B.sub(A)
        const TD = D.mul(T)
        tf.dispose(D)
        const M = A.add(TD)
        tf.dispose(TD)
        return M
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