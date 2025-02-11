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
            intensityMap      : { parameters: null, tensor: null},
            maximaMap         : { parameters: null, tensor: null},
            distanceMap       : { parameters: null, tensor: null},
            minimaDistanceMap : { parameters: null, tensor: null},
            maximaDistanceMap : { parameters: null, tensor: null},
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

    async generateMinimaDistanceMap(subDivision, maxIterations)
    {
        console.time('generateMinimaDistanceMap')

        if (!(this.computes.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`generateMinimaDistanceMap: intensityMap is not computed`)
        }
        
        const minimaDistanceMap = await this.computeMinimaDistanceMap(this.computes.intensityMap.tensor, subDivision, maxIterations)

        const parameters = {}
        parameters.shape = minimaDistanceMap.shape
        parameters.subDivision = subDivision
        parameters.invSubDivision = 1/subDivision
        parameters.dimensions = new THREE.Vector3().fromArray(minimaDistanceMap.shape.slice(0, 3).toReversed())
        parameters.spacing = new THREE.Vector3().copy(this.volume.parameters.spacing).multiplyScalar(subDivision)
        parameters.size = new THREE.Vector3().copy(parameters.dimensions).multiply(parameters.spacing)
        parameters.numBlocks = parameters.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
        parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
        parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
        parameters.maxBlockCount = parameters.dimensions.toArray().reduce((intersections, blocks) => intersections + blocks, -2)
        parameters.maxIterations = maxIterations

        this.computes.minimaDistanceMap.tensor = minimaDistanceMap
        this.computes.minimaDistanceMap.parameters = parameters
    
        console.log(this.computes.minimaDistanceMap.parameters)
        // console.log(this.computes.minimaDistanceMap.tensor.dataSync()) 
        console.timeEnd('generateMinimaDistanceMap')   
    }

    async generateMaximaDistanceMap(subDivision, maxIterations)
    {
        console.time('generateMaximaDistanceMap')

        if (!(this.computes.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`generateMaximaDistanceMap: intensityMap is not computed`)
        }
     
        const maximaDistanceMap = await this.computeMaximaDistanceMap(this.computes.intensityMap.tensor, subDivision, maxIterations)
     
        const parameters = {}
        parameters.shape = maximaDistanceMap.shape
        parameters.subDivision = subDivision
        parameters.invSubDivision = 1/subDivision
        parameters.dimensions = new THREE.Vector3().fromArray(maximaDistanceMap.shape.slice(0, 3).toReversed())
        parameters.spacing = new THREE.Vector3().copy(this.volume.parameters.spacing).multiplyScalar(subDivision)
        parameters.size = new THREE.Vector3().copy(parameters.dimensions).multiply(parameters.spacing)
        parameters.numBlocks = parameters.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
        parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
        parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
        parameters.maxBlockCount = parameters.dimensions.toArray().reduce((intersections, blocks) => intersections + blocks, -2)
        parameters.maxIterations = maxIterations

        this.computes.maximaDistanceMap.tensor = maximaDistanceMap
        this.computes.maximaDistanceMap.parameters = parameters
    
        console.log(this.computes.maximaDistanceMap.parameters)
        // console.log(this.computes.maximaDistanceMap.tensor.dataSync()) 
        console.timeEnd('generateMaximaDistanceMap')   
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
        const minimaMap = this.minPool3d(padded, divisions, strides, 'valid')
        tf.dispose(padded)
        await tf.nextFrame()

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
        const maximaMap = tf.maxPool3d(padded, divisions, strides, 'valid')
        tf.dispose(padded)
        await tf.nextFrame()

        return maximaMap
    }

    async computeMinimaDistanceMap(intensityMap, division, maxIterations)
    {
        // MAXIMA MAP

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


        // DISTANCE MAP

        // Initialize distance map and previous/next diffusion
        let diffusionMap = tf.tidy(() => tf.variable(tf.clone(minimaMap), true))
        let distanceMap  = tf.tidy(() => tf.variable(tf.zeros(minimaMap.shape, 'int32'), true))

        // Cap max iterations
        maxIterations = Math.min(maxIterations, 256)

        for (let i = 0; i < maxIterations; i++) 
        {
            tf.tidy(() => 
            {
                // Compute distance update
                const distance = tf.scalar(i, 'int32')
                const update = tf.greaterEqual(minimaMap, diffusionMap)

                // Update distance map
                distanceMap.assign(this.mix(distanceMap, distance, update))

                // Compute diffusion map with max pooling
                diffusionMap.assign(tf.maxPool3d(diffusionMap, [3, 3, 3], [1, 1, 1], 'same'))
            })

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }
        
        // Convert variable to tensor
        distanceMap = distanceMap.clone()

        // Cleanup
        tf.disposeVariables()
        await tf.nextFrame()

        
        // COMBINE RESULTS

        const minimaDistanceMap = tf.concat([minimaMap, distanceMap], 3)
        tf.dispose([minimaMap, distanceMap])

        return minimaDistanceMap
    }

    async computeMaximaDistanceMap(intensityMap, division, maxIterations)
    {
        // MAXIMA MAP

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


        // DISTANCE MAP

        // Initialize distance map and previous/next diffusion
        let diffusionMap = tf.tidy(() => tf.variable(tf.clone(maximaMap), true))
        let distanceMap  = tf.tidy(() => tf.variable(tf.zeros(maximaMap.shape, 'int32'), true))

        // Cap max iterations
        maxIterations = Math.min(maxIterations, 256)

        for (let i = 0; i < maxIterations; i++) 
        {
            tf.tidy(() => 
            {
                // Compute distance update
                const distance = tf.scalar(i, 'int32')
                const update = tf.greaterEqual(maximaMap, diffusionMap)

                // Update distance map
                distanceMap.assign(this.mix(distanceMap, distance, update))

                // Compute diffusion map with max pooling
                diffusionMap.assign(tf.maxPool3d(diffusionMap, [3, 3, 3], [1, 1, 1], 'same'))
            })

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }
        
        // Convert variable to tensor
        distanceMap = distanceMap.clone()

        // Cleanup
        tf.disposeVariables()
        await tf.nextFrame()

        
        // COMBINE RESULTS

        const maximaDistanceMap = tf.concat([maximaMap, distanceMap], 3)
        tf.dispose([maximaMap, distanceMap])

        return maximaDistanceMap
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
        const difference = tensorB.sub(tensorA)
        const scaled = difference.mul(tensorT)
        tf.dispose(difference)
        const mixed = tensorA.add(scaled)
        tf.dispose(scaled)
        return mixed
    }

}