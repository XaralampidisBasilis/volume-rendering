import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'
import MPRViewer from './MPRViewer'
import { computeBoundingBox, computeDistanceSubmap, downscaleLinear, downscaleNearest } from '../../Utils/TensorUtils'

export default class Computes extends EventEmitter
{
    constructor()
    {
        super()

        this.viewer = new MPRViewer()
        this.renderer = this.viewer.renderer
        this.resources = this.viewer.resources

        // Wait for resources
        this.resources.on('ready', () =>
        {
            this.setComputes()
        })
    }

    async setComputes()
    {
        console.time('Computes') 

        // tf.enableProdMode()
        await tf.ready()

        await tf.setBackend('webgl')
        await this.setIntensityMap()
        await this.setBinaryMap()
        await this.downscaleIntensityMap()
        await this.downscaleBinaryMap()
        
        await tf.setBackend('webgl')
        await this.setBoundingBox()
        await this.setDistanceMap()
     
        this.trigger('ready')
        console.timeEnd('Computes') 
    }

    async setIntensityMap()
    {
        console.time('setIntensityMap') 
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
        console.timeEnd('setIntensityMap') 
        // console.log(this.intensityMap.parameters)
        // console.log(this.intensityMap.tensor.dataSync())
    }

    async setBinaryMap()
    {
        console.time('setBinaryMap') 
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
        console.timeEnd('setBinaryMap') 
        // console.log(this.binaryMap.parameters)
        // console.log(this.binaryMap.tensor.dataSync())
    }

    async setBoundingBox()
    {
        console.time('setBoundingBox') 
        const boundingBox = await computeBoundingBox(this.binaryMap.tensor)
        const parameters = {}
        parameters.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
        parameters.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
        parameters.dimensions = new THREE.Vector3().subVectors(parameters.maxCoords, parameters.minCoords).addScalar(1)
        parameters.size = parameters.dimensions.clone().multiply(this.binaryMap.parameters.spacing)
        parameters.numCells = parameters.dimensions.toArray().reduce((count, dimension) => count * dimension, 1)
        parameters.maxCells = parameters.dimensions.toArray().reduce((count, dimension) => count + dimension, -2)

        this.boundingBox = {}
        this.boundingBox.parameters = parameters
        console.timeEnd('setBoundingBox') 
        // console.log(this.boundingBox.parameters)
    }

    async setDistanceMap()
    {
        console.time('setDistanceMap') 
        const begin = this.boundingBox.parameters.minCoords.toArray().toReversed().concat(0)
        const size = this.boundingBox.parameters.dimensions.toArray().toReversed().concat(1)
        const distanceMap = await computeDistanceSubmap(this.binaryMap.tensor, begin, size, 128)
        const maxTensor = distanceMap.max()
        const parameters = {...this.binaryMap.parameters}
        parameters.maxDistance = maxTensor.arraySync()  
        tf.dispose(maxTensor)

        this.distanceMap = {}
        this.distanceMap.tensor = distanceMap
        this.distanceMap.parameters = parameters
        console.timeEnd('setDistanceMap') 
        // console.log(this.distanceMap.parameters)
        // console.log(this.distanceMap.tensor)
        // console.log(this.distanceMap.tensor.dataSync())
    }

    async downscaleIntensityMap()
    {
        console.time('downscaleIntensityMap') 
        const downscaledMap = await downscaleLinear(this.intensityMap.tensor, 2)  

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
        const downscaledMap = await downscaleNearest(this.binaryMap.tensor, 2)  

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
        if (this.intensityMap) 
        {
            tf.dispose(this.intensityMap.tensor)
            this.intensityMap.tensor = null
            this.intensityMap.parameters = null
            this.intensityMap = null

        }

        if (this.binaryMap) 
        {
            tf.dispose(this.binaryMap.tensor)
            this.binaryMap.tensor = null
            this.binaryMap.parameters = null
            this.binaryMap = null
        }

        if (this.distanceMap) 
        {
            tf.dispose(this.distanceMap.tensor)
            this.distanceMap.tensor = null
            this.distanceMap.parameters = null
            this.distanceMap = null
        }

        if (this.boundingBox) 
        {
            this.boundingBox.parameters = null
            this.boundingBox = null
        }

        this.viewer =  null
        this.renderer = null
        this.resources = null

        console.log('Computes destroyed.')
    }
}