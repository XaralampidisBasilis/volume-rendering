import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'
import Experience from '../../Experience'

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
        // tf.enableProdMode()
        await tf.setBackend('webgl')
        await tf.ready()

        await this.generateIntensityMap()
        await this.generateBinaryMap()
        await this.generateBoundingBox()
        await this.generateDistanceMap()
        
        this.trigger('ready')
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
        parameters.minPosition = parameters.minCoords.clone().addScalar(0).multiply(this.binaryMap.parameters.spacing)
        parameters.maxPosition = parameters.maxCoords.clone().addScalar(1).multiply(this.binaryMap.parameters.spacing)
        parameters.dimensions = new THREE.Vector3().subVectors(parameters.maxCoords, parameters.minCoords).addScalar(1)
        parameters.size = parameters.dimensions.clone().multiply(this.binaryMap.parameters.spacing)
        parameters.numCells = parameters.dimensions.toArray().reduce((count, dimension) => count * dimension, 1)
        parameters.maxCells = parameters.dimensions.toArray().reduce((count, dimension) => count + dimension, -2)
        parameters.maxTraces = Math.ceil(parameters.size.length() / this.binaryMap.parameters.spacing.length())

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
        console.log(this.distanceMap.parameters)
        // console.log(this.distanceMap.tensor)
        // console.log(this.distanceMap.tensor.dataSync())
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
        const occupancySubmap = occupancyMap.slice(begin, size)
        const distanceSubmap = await this.computeDistanceMap(occupancySubmap, maxIterations)
        tf.dispose(occupancySubmap)

        const shape = occupancyMap.shape
        const paddings = shape.map((dimension, i) => [begin[i], dimension - begin[i] - size[i]])
        const distanceMap = distanceSubmap.pad(paddings, 1)
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

    async computeBoundingBox(binaryTensor) 
    {
        const coords = []
        const collapsedX = binaryTensor.any([1, 2, 3]) 
        coords[2] = await this.argBounds(collapsedX)
        tf.dispose(collapsedX)

        const collapsedYZ = binaryTensor.any([0, 3]) 
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
}