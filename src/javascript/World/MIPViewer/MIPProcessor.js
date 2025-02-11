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
        // tf.enableProdMode()
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

        // console.log(this.computes.intensityMap.parameters)
        // console.log(this.computes.intensityMap.tensor.dataSync())
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
    
        // console.log(this.computes.maximaMap.parameters)
        // console.log(this.computes.maximaMap.tensor.dataSync())    
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

        // console.log(this.computes.extremaMap.parameters)
        // console.log(this.computes.extremaMap.tensor.dataSync())    
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
        
        console.log(this.computes.distanceMap.parameters)
        // console.log(this.computes.distanceMap.tensor.dataSync())    
    }
    
    // Helpers

    async computeMinimaMap(intensityMap, division) 
    {
        // Scalars for threshold and output scaling
        const strides = [division, division, division]
        const divisions = strides.map(x => x + 1)

        // Calculate necessary padding for valid subdivisions and boundary handling
        const divisible = intensityMap.shape
            .map((dimension, i) => Math.ceil((dimension - divisions[i]) / strides[i]) + 1)
            .map((dimension, i) => dimension * strides[i] + divisions[i])
        const padding = intensityMap.shape.map((dimension, i) => [1, divisible[i] - dimension - 1])
        padding[3] = [0, 0]

        // Symmetric padding to handle boundaries by adding zeros
        // const padded = tf.mirrorPad(intensityMap, padZ`ding, 'symmetric')
        const padded = tf.pad(intensityMap, padding)

        // Max pooling for upper bound detection
        const minPool = this.minPool3d(padded, divisions, strides, 'valid')
        tf.dispose(padded)
        await tf.nextFrame()

        // Tensor must be normalized in [0, 1]
        const scalar255 = tf.scalar(255)
        const minimaMap = tf.tidy(() => minPool.mul(scalar255).clipByValue(0, 255).floor().cast('int32'))
        tf.dispose(minPool, scalar255)

        return minimaMap
    }

    async computeMaximaMap(intensityMap, division) 
    {
        // Scalars for threshold and output scaling
        const strides = [division, division, division]
        const divisions = strides.map(x => x + 1)

        // Calculate necessary padding for valid subdivisions and boundary handling
        const divisible = intensityMap.shape
            .map((dimension, i) => Math.ceil((dimension - divisions[i]) / strides[i]) + 1)
            .map((dimension, i) => dimension * strides[i] + divisions[i])
        const padding = intensityMap.shape.map((dimension, i) => [1, divisible[i] - dimension - 1])
        padding[3] = [0, 0]

        // Symmetric padding to handle boundaries by adding zeros
        // const padded = tf.mirrorPad(intensityMap, padZ`ding, 'symmetric')
        const padded = tf.pad(intensityMap, padding)

        // Max pooling for upper bound detection
        const maxPool = tf.maxPool3d(padded, divisions, strides, 'valid')
        tf.dispose(padded)
        await tf.nextFrame()

        // Tensor must be normalized in [0, 1]
        const scalar255 = tf.scalar(255)
        const maximaMap = tf.tidy(() => maxPool.mul(scalar255).clipByValue(0, 255).ceil().cast('int32'))
        tf.dispose(maxPool, scalar255)

        return maximaMap
    }

    async computeDistanceMap(occupancyMap, maxIters) 
    {
        // Initialize previous/next diffusion
        let diffusionPrev = tf.zeros(occupancyMap.shape, 'bool')
        let diffusionNext = tf.clone(occupancyMap)

        // Initialize distance map 
        let distanceMap = tf.zeros(occupancyMap.shape, 'int32')

        for (let i = 0; i <= maxIters; i++) 
        {
            const scalarIter = tf.scalar(i, 'int32')

            // Compute distance update
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distanceUpdate = diffusionUpdate.mul(scalarIter)
            tf.dispose([diffusionUpdate, scalarIter])

            // Update distance map
            const distanceMapTemp = distanceMap.add(distanceUpdate)
            tf.dispose([distanceMap, distanceUpdate])
            distanceMap = distanceMapTemp

            // Update previous diffusion 
            tf.dispose(diffusionPrev)
            diffusionPrev = diffusionNext.clone()

            // Compute next diffusion with max pooling
            tf.dispose(diffusionNext)
            diffusionNext = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')

            // Await for garbage disposal
            await tf.nextFrame()
        }

        // Compute final distance update
        const scalarMax = tf.scalar(maxIters, 'int32')
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        const distanceUpdate = diffusionUpdate.mul(scalarMax)
        tf.dispose([diffusionNext, diffusionPrev, diffusionUpdate, scalarMax])
        await tf.nextFrame()

        // Update final distance map
        const distanceMapTemp = distanceMap.add(distanceUpdate)
        tf.dispose([distanceMap, distanceUpdate])
        distanceMap = distanceMapTemp
        await tf.nextFrame()

        // Return the final distance map
        return distanceMap
    }

    
    async computeMaximaDistanceMap(maximaMap, maxIterations) 
    {
        // Initialize variables
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
            const distanceMapTemp = this.mix(distanceMap, scalarDistance, updateDistance)
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
    
    minPool3d(tensor4d, filterSize, strides, pad)
    {
        const scalarNegativeOne = tf.scalar(-1, 'float32')
        const negative = tensor4d.mul(scalarNegativeOne)
        const negMaxPool = tf.maxPool3d(negative, filterSize, strides, pad)
        tf.dispose(negative)
        const tensorMinPool = negMaxPool.mul(scalarNegativeOne)
        tf.dispose([negMaxPool, scalarNegativeOne])
        return tensorMinPool
    } 

    mix(tensorA, tensorB, tensorT)
    {
        const D = tensorB.sub(tensorA)
        const TD = D.mul(tensorT)
        tf.dispose(D)
        const M = tensorA.add(TD)
        tf.dispose(TD)
        return M
    }

}