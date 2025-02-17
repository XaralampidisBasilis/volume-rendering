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
            intensityMap          : { parameters: null, tensor: null},
            maximaMap             : { parameters: null, tensor: null},
            distanceMap           : { parameters: null, tensor: null},
            anisotropicDistanceMap: { parameters: null, tensor: null},
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
            throw new Error(`generateMaximaMap: intensityMap is not computed`)
        }
     
        const maximaMap = await this.computeMaximaMap(this.computes.intensityMap.tensor, subDivision)
        const parameters = {}

        parameters.shape = maximaMap.shape
        parameters.subDivision = subDivision
        parameters.invSubDivision = 1/subDivision
        parameters.dimensions = new THREE.Vector3().fromArray(maximaMap.shape.slice(0, 3).toReversed())
        parameters.spacing = new THREE.Vector3().copy(this.volume.parameters.spacing).multiplyScalar(subDivision)
        parameters.size = new THREE.Vector3().copy(parameters.dimensions).multiply(parameters.spacing)
        parameters.spacingLength = parameters.spacing.length()
        parameters.sizeLength = parameters.size.length()
        parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
        parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
        parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
        parameters.numBlocks = parameters.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        parameters.maxBlockCount = parameters.dimensions.toArray().reduce((intersections, blocks) => intersections + blocks, -2)

        this.computes.maximaMap.tensor = maximaMap
        this.computes.maximaMap.parameters = parameters
    
        // console.log(this.computes.maximaMap.parameters)
        // console.log(this.computes.maximaMap.tensor.dataSync())    
    }

    async generateDistanceMap(maxIterations)
    {
        if (!(this.computes.maximaMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`generateDistanceMap: maximaMap is not computed`)
        }

        const distanceMap = await this.computeDistanceMap(this.computes.maximaMap.tensor, maxIterations)
        
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

    async generateAnisotropicDistanceMap()
    {
        if (!(this.computes.maximaMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`generateAnisotropicDistanceMap: maximaMap is not computed`)
        }

        console.time('generateAnisotropicDistanceMap')
        const anisotropicDistanceMap = await this.computeAnisotropicDistanceMap(this.computes.maximaMap.tensor)
        console.timeEnd('generateAnisotropicDistanceMap')

        const parameters = {...this.computes.maximaMap.parameters}

        this.computes.anisotropicDistanceMap.tensor = anisotropicDistanceMap  
        this.computes.anisotropicDistanceMap.parameters = parameters
        
        // console.log(this.computes.anisotropicDistanceMap.parameters)
        // console.log(this.computes.anisotropicDistanceMap.tensor.dataSync()) 
    }
    
    // Helpers

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

    async computeDistanceMap(maximaMap, maxIterations)
    {
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

        return distanceMap
    }

    async computeDiagonalDistanceMap(maximaMap, maxIterations, index)
    {
        const reverse = (tensor, index) =>
        {
            return tf.tidy(() =>
            {   
                switch (index)
                {
                    case 0: return tensor.reverse(0).reverse(1).reverse(2) // octant (- - -)
                    case 1: return tensor.reverse(0).reverse(1)            // octant (- - +)
                    case 2: return tensor.reverse(0).reverse(2)            // octant (- + -)
                    case 3: return tensor.reverse(0)                       // octant (- + +)
                    case 4: return tensor.reverse(1).reverse(2)            // octant (+ - -)
                    case 5: return tensor.reverse(1)                       // octant (+ - +)
                    case 6: return tensor.reverse(2)                       // octant (+ + -)
                    case 7: return tensor.clone();                         // octant (+ + +)
                }
            })
        }

        // Initialize distance map and previous/next diffusion
        let reverseMap = reverse(maximaMap, index)
        let diffusionMap = tf.tidy(() => tf.variable(tf.clone(reverseMap), true))
        let distanceMap  = tf.tidy(() => tf.variable(tf.zeros(reverseMap.shape, 'int32'), true))

        // Reflect the map to align with direction
        reverse(diffusionMap, index)

        for (let i = 0; i < maxIterations; i++) 
        {
            tf.tidy(() => 
            {
                // Compute distance update
                const distance = tf.scalar(i, 'int32')
                const update = tf.greaterEqual(reverseMap, diffusionMap)

                // Update distance map
                distanceMap.assign(this.mix(distanceMap, distance, update))

                // Compute diffusion map with max pooling
                diffusionMap.assign(tf.maxPool3d(diffusionMap, [2, 2, 2], [1, 1, 1], 'same'))
            })

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }

        // Reflect back the distance map and convert variable to tensor
        distanceMap = reverse(distanceMap, index)

        // Cleanup
        tf.disposeVariables()
        await tf.nextFrame()

        return distanceMap
    }

    async computeAnisotropicDistanceMap(maximaMap)
    {
        // Octant distance maps
        const distanceMap0 = await this.computeDiagonalDistanceMap(maximaMap, 16, 0)
        const distanceMap1 = await this.computeDiagonalDistanceMap(maximaMap, 16, 1)
        const distanceMap2 = await this.computeDiagonalDistanceMap(maximaMap, 16, 2)
        const distanceMap3 = await this.computeDiagonalDistanceMap(maximaMap, 16, 3)
        const distanceMap4 = await this.computeDiagonalDistanceMap(maximaMap, 16, 4)
        const distanceMap5 = await this.computeDiagonalDistanceMap(maximaMap, 16, 5)
        const distanceMap6 = await this.computeDiagonalDistanceMap(maximaMap, 16, 6)
        const distanceMap7 = await this.computeDiagonalDistanceMap(maximaMap, 16, 7)

        // Bit packing
        const distanceMap01 = tf.tidy(() => tf.add(distanceMap0, distanceMap1.mul(tf.scalar(16, 'int32'))))
        const distanceMap23 = tf.tidy(() => tf.add(distanceMap2, distanceMap3.mul(tf.scalar(16, 'int32'))))
        const distanceMap45 = tf.tidy(() => tf.add(distanceMap4, distanceMap5.mul(tf.scalar(16, 'int32'))))
        const distanceMap67 = tf.tidy(() => tf.add(distanceMap6, distanceMap7.mul(tf.scalar(16, 'int32'))))

        // const map = tf.tidy(() => distanceMap0.minimum(distanceMap1).minimum(distanceMap2).minimum(distanceMap3).minimum(distanceMap4).minimum(distanceMap5).minimum(distanceMap6).minimum(distanceMap7))
        // console.log(map.sub(this.computes.distanceMap.tensor).dataSync())

        // Anisotropic distance map
        const distanceMap = tf.concat([distanceMap01, distanceMap23, distanceMap45, distanceMap67], 3)

        // Disposals
        tf.dispose([distanceMap0, distanceMap1, distanceMap2, distanceMap3, distanceMap4, distanceMap5, distanceMap6, distanceMap7])
        tf.dispose([distanceMap01, distanceMap23, distanceMap45, distanceMap67])

        // Return map
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
        const difference = tensorB.sub(tensorA)
        const scaled = difference.mul(tensorT)
        tf.dispose(difference)
        const mixed = tensorA.add(scaled)
        tf.dispose(scaled)
        return mixed
    }

}