import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'

const timeit = (name, callback) => 
{ 
    console.time(name) 
    callback()
    console.timeEnd(name) 
}

export default class MPRProcessor extends EventEmitter
{
    constructor(volume)
    {
        super()

        this.setTensorflow()
        this.setIntensityMap(volume)
        this.trigger('ready')
    }

    async setTensorflow()
    {
        // tf.enableProdMode()
        await tf.setBackend('webgl')
        await tf.ready()
    }

    setIntensityMap(volume)
    {
        const parameters = 
        {
            dimensions       : new THREE.Vector3().fromArray(volume.dimensions),
            spacing          : new THREE.Vector3().fromArray(volume.spacing),
            size             : new THREE.Vector3().fromArray(volume.size),
            spacingLength    : new THREE.Vector3().fromArray(volume.spacing).length(),
            sizeLength       : new THREE.Vector3().fromArray(volume.size).length(),
            invDimensions    : new THREE.Vector3().fromArray(volume.dimensions.map(x => 1/x)),
            invSpacing       : new THREE.Vector3().fromArray(volume.spacing.map(x => 1/x)),
            invSize          : new THREE.Vector3().fromArray(volume.size.map(x => 1/x)),
            numVoxels        : volume.dimensions.reduce((voxels, dimension) => voxels * dimension, 1),
            shape            : volume.dimensions.toReversed().concat(1),
            minIntensity     : volume.min,
            maxIntensity     : volume.max,
        }

        const data = new Float32Array(volume.data)
        const min = volume.min
        const scale = 1 / (volume.max - volume.min)

        for (let i = 0; i < data.length; i++) 
        {
            data[i] = (data[i] - min) * scale;
        }

        const intensityMap = tf.tensor4d(data, parameters.shape,'float32')                

        this.intensityMap = {}
        this.intensityMap.tensor = intensityMap
        this.intensityMap.parameters = parameters

        // console.log(this.computes.intensityMap.parameters)
        // console.log(this.computes.intensityMap.tensor.dataSync())
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