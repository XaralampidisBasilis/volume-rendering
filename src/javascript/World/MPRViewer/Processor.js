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
}