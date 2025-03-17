import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'
import Experience from '../../Experience'
import { distance } from 'mathjs'

export default class Processor extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
    }

    async compute()
    {
        console.time('compute') 
        // tf.enableProdMode()
        await tf.ready()

        await tf.setBackend('webgl')
        await this.generateIntensityMap()
        await this.generateBinaryMap()
        // await this.downscaleIntensityMap()
        // await this.downscaleBinaryMap()

        await tf.setBackend('webgl')
        await this.generateBoundingBox()
        await this.generateDistanceMap()
        
        this.trigger('ready')
        console.timeEnd('compute') 
    }

    async generateIntensityMap()
    {
        console.time('generateIntensityMap') 
        const source = this.resources.items.intensityMap
        const parameters = 
        {
            dimensions       : new THREE.Vector3().fromArray(source.dimensions),
            spacing          : new THREE.Vector3().fromArray(source.spacing),
            size             : new THREE.Vector3().fromArray(source.size),
            invDimensions    : new THREE.Vector3().fromArray(source.dimensions.map(x => 1/x)),
            invSpacing       : new THREE.Vector3().fromArray(source.spacing.map(x => 1/x)),
            invSize          : new THREE.Vector3().fromArray(source.size.map(x => 1/x)),
            spacingLength    : new THREE.Vector3().fromArray(source.spacing).length(),
            sizeLength       : new THREE.Vector3().fromArray(source.size).length(),
            numVoxels        : source.dimensions.reduce((voxels, dimension) => voxels * dimension, 1),
            maxVoxels        : source.dimensions.reduce((voxels, dimension) => voxels + dimension, -2),
            shape            : source.dimensions.toReversed().concat(1),
        }

        const min = source.min
        const range = source.max - source.min
        const data = new Float32Array(source.data)
        const intensityMap = tf.tidy(() => tf.tensor4d(data, parameters.shape,'float32').sub([min]).div([range]))        

        this.intensityMap = {}
        this.intensityMap.tensor = intensityMap
        this.intensityMap.parameters = parameters
        console.timeEnd('generateIntensityMap') 
        // console.log(this.intensityMap.parameters)
        // console.log(this.intensityMap.tensor.dataSync())
    }

    async generateBinaryMap()
    {
        console.time('generateBinaryMap') 
        const source = this.resources.items.binaryMap
        const parameters = 
        {
            dimensions       : new THREE.Vector3().fromArray(source.dimensions),
            spacing          : new THREE.Vector3().fromArray(source.spacing),
            size             : new THREE.Vector3().fromArray(source.size),
            invDimensions    : new THREE.Vector3().fromArray(source.dimensions.map(x => 1/x)),
            invSpacing       : new THREE.Vector3().fromArray(source.spacing.map(x => 1/x)),
            invSize          : new THREE.Vector3().fromArray(source.size.map(x => 1/x)),
            spacingLength    : new THREE.Vector3().fromArray(source.spacing).length(),
            sizeLength       : new THREE.Vector3().fromArray(source.size).length(),
            numVoxels        : source.dimensions.reduce((voxels, dimension) => voxels * dimension, 1),
            maxVoxels        : source.dimensions.reduce((voxels, dimension) => voxels + dimension, -2),
            shape            : source.dimensions.toReversed().concat(1),
        }

        const data = new Uint8ClampedArray(source.data)
        const binaryMap = tf.tidy(() => tf.tensor4d(data, parameters.shape,'bool'))         

        this.binaryMap = {}
        this.binaryMap.tensor = binaryMap
        this.binaryMap.parameters = parameters
        console.timeEnd('generateBinaryMap') 
        // console.log(this.binaryMap.parameters)
        // console.log(this.binaryMap.tensor.dataSync())
    }

    async generateBoundingBox()
    {
        console.time('generateBoundingBox') 
        const boundingBox = await this.computeBoundingBox(this.binaryMap.tensor)
        const parameters = {}
        parameters.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
        parameters.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
        parameters.dimensions = new THREE.Vector3().subVectors(parameters.maxCoords, parameters.minCoords).addScalar(1)
        parameters.size = parameters.dimensions.clone().multiply(this.binaryMap.parameters.spacing)
        parameters.numCells = parameters.dimensions.toArray().reduce((count, dimension) => count * dimension, 1)
        parameters.maxCells = parameters.dimensions.toArray().reduce((count, dimension) => count + dimension, -2)

        this.boundingBox = {}
        this.boundingBox.parameters = parameters
        console.timeEnd('generateBoundingBox') 
        // console.log(this.boundingBox.parameters)
    }

    async generateDistanceMap()
    {
        console.time('generateDistanceMap') 
        const begin = this.boundingBox.parameters.minCoords.toArray().toReversed().concat(0)
        const size = this.boundingBox.parameters.dimensions.toArray().toReversed().concat(1)
        const distanceMap = await this.computeDistanceSubmap(this.binaryMap.tensor, begin, size, 128)
        const maxTensor = distanceMap.max()
        const parameters = {...this.binaryMap.parameters}
        parameters.maxDistance = maxTensor.arraySync()  
        tf.dispose(maxTensor)

        this.distanceMap = {}
        this.distanceMap.tensor = distanceMap
        this.distanceMap.parameters = parameters
        console.timeEnd('generateDistanceMap') 
        // console.log(this.distanceMap.parameters)
        // console.log(this.distanceMap.tensor)
        // console.log(this.distanceMap.tensor.dataSync())
    }

    async downscaleIntensityMap()
    {
        console.time('downscaleIntensityMap') 
        const downscaledMap = await this.downscaleLinear(this.intensityMap.tensor, 2)  

        const parameters = {}
        parameters.shape = downscaledMap.shape
        parameters.dimensions = new THREE.Vector3().fromArray(downscaledMap.shape.slice(0, 3).toReversed())
        parameters.size = new THREE.Vector3().copy(this.intensityMap.parameters.size)
        parameters.spacing = new THREE.Vector3().copy(parameters.size).divide(parameters.dimensions)
        parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
        parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
        parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
        parameters.spacingLength = parameters.spacing.length()
        parameters.sizeLength = parameters.size.length()
        parameters.numVoxels = parameters.dimensions.toArray().reduce((voxels, dimension) => voxels * dimension, 1)
        parameters.maxVoxels = parameters.dimensions.toArray().reduce((voxels, dimension) => voxels + dimension, -2)

        tf.dispose(this.intensityMap.tensor)
        this.intensityMap.tensor = downscaledMap
        this.intensityMap.parameters = parameters

        console.timeEnd('downscaleIntensityMap') 
        // console.log(this.intensityMap.parameters)
        // console.log(this.intensityMap.tensor.dataSync())
    }

    async downscaleBinaryMap()
    {
        console.time('downscaleBinaryMap') 
        const downscaledMap = await this.downscaleNearest(this.binaryMap.tensor, 2)  

        const parameters = {}
        parameters.shape = downscaledMap.shape
        parameters.dimensions = new THREE.Vector3().fromArray(downscaledMap.shape.slice(0, 3).toReversed())
        parameters.size = new THREE.Vector3().copy(this.binaryMap.parameters.size)
        parameters.spacing = new THREE.Vector3().copy(parameters.size).divide(parameters.dimensions)
        parameters.invDimensions = new THREE.Vector3().fromArray(parameters.dimensions.toArray().map(x => 1/x))
        parameters.invSpacing = new THREE.Vector3().fromArray(parameters.spacing.toArray().map(x => 1/x))
        parameters.invSize = new THREE.Vector3().fromArray(parameters.size.toArray().map(x => 1/x))
        parameters.spacingLength = parameters.spacing.length()
        parameters.sizeLength = parameters.size.length()
        parameters.numVoxels = parameters.dimensions.toArray().reduce((voxels, dimension) => voxels * dimension, 1)
        parameters.maxVoxels = parameters.dimensions.toArray().reduce((voxels, dimension) => voxels + dimension, -2)

        tf.dispose(this.binaryMap.tensor)
        this.binaryMap.tensor = downscaledMap
        this.binaryMap.parameters = parameters

        console.timeEnd('downscaleBinaryMap') 
        // console.log(this.binaryMap.parameters)
        // console.log(this.binaryMap.tensor.dataSync())
    }

    destroy() 
    {
        if (this.intensityMap.tensor instanceof tf.Tensor) 
        {
            tf.dispose(this.intensityMap.tensor)
            this.intensityMap.tensor = null
        }

        this.intensityMap.parameters = null
        this.intensityMap = null

        console.log('MPRProcessor destroyed.')
    }

    // tensor functions

    async computeDistanceSubmap(occupancyMap, begin, size, maxIterations)
    {
        const occupancySubmap = tf.slice4d(occupancyMap, begin, size)
        const distanceSubmap = await this.computeDistanceMap(occupancySubmap, maxIterations)
        tf.dispose(occupancySubmap)

        const shape = occupancyMap.shape
        const paddings = shape.map((dimension, i) => [begin[i], dimension - begin[i] - size[i]])
        const distanceMap = tf.pad4d(distanceSubmap, paddings, 1)
        tf.dispose(distanceSubmap)

        return distanceMap
    }

    async computeDistanceMap(occupancyMap, maxIterations) 
    {
        // Initialize distance map and previous/next diffusion
        let distanceMap   = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'int32'), true))
        let diffusionPrev = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'bool'), true))
        let diffusionNext = tf.tidy(() => tf.variable(tf.clone(occupancyMap), true))
        
        for (let n = 0; n <= maxIterations; n++) 
        {
            // Compute distance update
            const scalarIter = tf.scalar(n, 'int32')
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distanceUpdate = diffusionUpdate.mul(scalarIter)

            // Update distance map
            const distanceMapUpdate = distanceMap.add(distanceUpdate)
            distanceMap.assign(distanceMapUpdate)

            // Update previous diffusion state
            diffusionPrev.assign(diffusionNext)

            // Compute next diffusion with max pooling
            const diffusionNextUpdate = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
            diffusionNext.assign(diffusionNextUpdate)

            // Await for garbage disposal
            tf.dispose([diffusionNextUpdate, distanceMapUpdate, distanceUpdate, diffusionUpdate, scalarIter])
            await tf.nextFrame()
        }

        // Compute final distance update
        const scalarMax = tf.scalar(maxIterations, 'int32')
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        const distanceUpdate = diffusionUpdate.mul(scalarMax)

        // Update final distance map
        distanceMap = distanceMap.add(distanceUpdate)

        // Cleanup
        tf.dispose([distanceUpdate, diffusionUpdate, scalarMax])
        tf.disposeVariables()
        await tf.nextFrame()

        // Return the final distance map
        return distanceMap
    }

    async computeBoundingBox(binaryMap) 
    {
        const coords = []
        const collapsedX = binaryMap.any([1, 2, 3]) 
        coords[2] = await this.argBounds(collapsedX)
        tf.dispose(collapsedX)

        const collapsedYZ = binaryMap.any([0, 3]) 
        const collapsedY = collapsedYZ.any(1) 
        coords[1] = await this.argBounds(collapsedY)
        tf.dispose(collapsedY)

        const collapsedZ = collapsedYZ.any(0) 
        coords[0] = await this.argBounds(collapsedZ)
        tf.dispose([collapsedZ, collapsedYZ])

        const minCoords = [coords[0][0], coords[1][0], coords[2][0]]
        const maxCoords = [coords[0][1], coords[1][1], coords[2][1]]

        return { minCoords, maxCoords }    
    }

    async argBounds(binaryArray)
    {
        const coords = await tf.whereAsync(binaryArray)
        const indices = coords.arraySync().flat()
        tf.dispose(coords)

        return (indices.length) ? [indices[0], indices[indices.length - 1]] : [0, 0]
    }
    
    async downscaleLinear(intensityMap, scale)
    {
        const newShape = intensityMap.shape.map((size) => Math.ceil(size / scale))

        const resized0 = await this.resizeLinear(intensityMap, 0, newShape[0])
        await tf.nextFrame()

        const resized1 = await this.resizeLinear(resized0, 1, newShape[1])
        tf.dispose(resized0)
        await tf.nextFrame()

        const resized2 = await this.resizeLinear(resized1, 2, newShape[2])
        tf.dispose(resized1)
        await tf.nextFrame()

        const resized3 = await this.resizeLinear(resized2, 3, newShape[3])
        tf.dispose(resized2)
        await tf.nextFrame()

        return resized3
    }

    async downscaleNearest(binaryMap, scale)
    {
        const newShape = binaryMap.shape.map((size) => Math.ceil(size / scale))

        const resized0 = await this.resizeNearest(binaryMap, 0, newShape[0])
        await tf.nextFrame()

        const resized1 = await this.resizeNearest(resized0, 1, newShape[1])
        tf.dispose(resized0)
        await tf.nextFrame()

        const resized2 = await this.resizeNearest(resized1, 2, newShape[2])
        tf.dispose(resized1)
        await tf.nextFrame()

        const resized3 = await this.resizeNearest(resized2, 3, newShape[3])
        tf.dispose(resized2)
        await tf.nextFrame()

        return resized3
    }

    async resizeLinear(tensor, axis, newSize) 
    {
        return tf.tidy(() => 
        {
            // Compute indices for interpolation
            const delta = 1 / newSize
            const indices = tf.linspace(0, newSize - 1, newSize)
            const percents = indices.add(0.5).mul(delta) // normalized indices
            
            // Compute the sample indices 
            const size = tensor.shape[axis]
            const samples = percents.mul(size).sub(0.5)
            const samplesFloor = tf.clipByValue(tf.floor(samples).toInt(), 0, size - 1)  // lower indices, clipped
            const samplesCeil = tf.clipByValue(tf.ceil(samples).toInt(), 0, size - 1)    // upper indices, clipped

            // Compute interpolation weights
            const lerpWeights = samples.sub(tf.floor(samples))   // fractional part for interpolation
            const lerpShape = new Array(tensor.shape.length).fill(1)
            lerpShape[axis] = lerpWeights.size // match dimensions along the interpolation axis

            // Gather slices along the specified axis
            const expandedFloor = tf.gather(tensor, samplesFloor, axis)
            const expandedCeil = tf.gather(tensor, samplesCeil, axis)
            const expandedWeights = tf.reshape(lerpWeights, lerpShape) // reshape for broadcasting

            // Perform linear interpolation
            const interpolated = this.mix(expandedFloor, expandedCeil, expandedWeights)
            return interpolated
        })
    }

    async resizeNearest(tensor, axis, newSize) 
    {
        return tf.tidy(() => 
        {
            // Compute new indices in normalized space
            const delta = 1 / newSize
            const indices = tf.linspace(0, newSize - 1, newSize)
            const percents = indices.add(0.5).mul(delta) // normalized indices
    
            // Map to the original tensor index space
            const size = tensor.shape[axis]
            const samples = percents.mul(size).sub(0.5)
    
            // Use nearest neighbor rounding (instead of linear interpolation)
            const nearestIndices = tf.round(samples).toInt() // Round to nearest index
            const nearestClipped = tf.clipByValue(nearestIndices, 0, size - 1) // Ensure valid indices
    
            // Gather values from the original tensor
            const resized = tf.gather(tensor, nearestClipped, axis)
            return resized
        });
    }

    mix(A, B, T)
    {
        const difference = B.sub(A)
        tf.dispose(B)
        const offset = difference.mul(T)
        tf.dispose(T)
        const mixed = A.add(offset)
        tf.dispose(A)
        return mixed
    }

   
}