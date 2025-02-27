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
        
        this.trigger('ready')
    }

    async generateIntensityMap()
    {
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
        // console.log(this.intensityMap.parameters)
        // console.log(this.intensityMap.tensor.dataSync())
    }

    async generateBinaryMap()
    {
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
        // console.log(this.binaryMap.parameters)
        // console.log(this.binaryMap.tensor.dataSync())
    }

    async generateBoundingBox()
    {
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
        console.log(this.boundingBox.parameters)
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

    async computeBoundingBox(binaryTensor) 
    {
        console.time('computeBoundingBox')
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
        console.timeEnd('computeBoundingBox')

        return { minCoords, maxCoords }    
    }

    async argBounds(binaryArray)
    {
        console.time('argBounds')
        const coords = await tf.whereAsync(binaryArray)
        const indices = coords.arraySync().flat()
        tf.dispose(coords)
        console.timeEnd('argBounds')

        return (indices.length) ? [indices[0], indices[indices.length - 1]] : [0, 0]
    }

    async argBoundsSync(binaryArray) 
    {
        console.time('argBoundsSync')
        const array = binaryArray.dataSync()
    
        let firstIndex;
        let lastIndex;

        for (firstIndex = 0; firstIndex <= array.length - 1; firstIndex++) 
        {
            if (array[firstIndex]) 
            {
                break
            }
        }

        for (lastIndex = array.length - 1; lastIndex >= 0; lastIndex--) 
        {
            if (array[lastIndex]) 
            {
                break
            }
        }
        console.timeEnd('argBoundsSync')
        
        return (firstIndex <= lastIndex) ? [firstIndex, lastIndex] : [0, 0]
    }


}