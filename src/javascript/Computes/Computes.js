import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../Utils/EventEmitter'
import Experience from '../Experience'
import VolumeMap from './Maps/VolumeMap'
import InterpolationMap from './Maps/InterpolationMap'
import ExtremaMap from './Maps/ExtremaMap'
import OccupancyMap from './Maps/OccupancyMap'
import IsotropicDistanceMap from './Maps/IsotropicDistanceMap'
import AnisotropicDistanceMap from './Maps/AnisotropicDistanceMap'
import ExtendedAnisotropicDistanceMap from './Maps/ExtendedAnisotropicDistanceMap'

export default class Computes extends EventEmitter
{
    static instance = null

    constructor()
    {
        super()

        if (Computes.instance) 
        {
            return Computes.instance
        }
        Computes.instance = this

        this.experience = new Experience()
        this.renderer = this.experience.renderer
        this.configs = this.experience.configs
        this.resources = this.experience.resources
        
        this.setMaps()
    }

    setMaps()
    {
        this.volumeMap = new VolumeMap()
        this.interpolationMap = new InterpolationMap()
        this.extremaMap = new ExtremaMap()
        this.occupancyMap = new OccupancyMap()
        this.isotropicDistanceMap = new IsotropicDistanceMap()
        this.anisotropicDistanceMap = new AnisotropicDistanceMap()
        this.extendedAnisotropicDistanceMap = new ExtendedAnisotropicDistanceMap()
        this.resolveDistanceMap()
    }

    resolveDistanceMap()
    {
        this.skippingMethod = this.configs.skippingMethod
        this.distanceMap = this.isotropicDistanceMap

        if (this.skippingMethod === 'anisotropicDistance')
            this.distanceMap = this.anisotropicDistanceMap
        
        if (this.skippingMethod === 'extendedAnisotropicDistance')
            this.distanceMap = this.extendedAnisotropicDistanceMap
    }

    start()
    {
        console.time('start@Computes') 

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.volumeMap.tensor.dispose()

        this.extremaMap.computeTensor()
        this.interpolationMap.computeTexture()
        this.interpolationMap.tensor.dispose()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.computeTexture()
        this.occupancyMap.tensor.dispose()

        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('start@Computes') 
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('')
    }

    change(event)
    {
        if      (event.key === 'isosurfaceValue'    ) this.onChangeIsosurfaceValue(event)
        else if (event.key === 'blockSize'          ) this.onChangeBlockSize(event)
        else if (event.key === 'downscaleFactor'    ) this.onChangeDownscaleFactor(event)
        else if (event.key === 'interpolationMethod') this.onChangeInterpolationMethod(event)
        else if (event.key === 'skippingMethod'     ) this.onChangeSkippingMethod(event)
    }

    onChangeIsosurfaceValue(event)
    {
        console.time('onChangeIsosurfaceValue@Computes') 

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.updateTexture()
        this.occupancyMap.tensor.dispose()
        
        this.distanceMap.updateTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeIsosurfaceValue@Computes')
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('') 
    }

    onChangeBlockSize(event)
    {
        console.time('onChangeBlockSize@Computes') 

        this.occupancyMap.texture.dispose()
        this.distanceMap.texture.dispose()
        this.extremaMap.tensor.dispose()

        this.interpolationMap.restoreTensor()
        this.extremaMap.computeTensor()
        this.interpolationMap.tensor.dispose()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.computeTexture()
        this.occupancyMap.tensor.dispose()
        
        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeBlockSize@Computes')
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('') 
    }

    onChangeDownscaleFactor(event)
    {
        console.time('onChangeDownscaleFactor@Computes') 

        this.interpolationMap.texture.dispose()
        this.occupancyMap.texture.dispose()
        this.distanceMap.texture.dispose()
        this.extremaMap.tensor.dispose()

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.volumeMap.tensor.dispose()

        this.extremaMap.computeTensor()
        this.interpolationMap.computeTexture()
        this.interpolationMap.tensor.dispose()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.computeTexture()
        this.distanceMap.computeTexture()

        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeDownscaleFactor@Computes') 
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('')
    }

    onChangeInterpolationMethod(event)
    {
        console.time('onChangeInterpolationMethod@Computes') 

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.updateTexture()
        this.occupancyMap.tensor.dispose()

        this.distanceMap.updateTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeInterpolationMethod@Computes') 
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('')
    }

    onChangeSkippingMethod(event)
    {
        console.time('onChangeSkippingMethod@Computes') 

        this.distanceMap.texture.dispose()
        this.resolveDistanceMap()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        this.occupancyMap.tensor.dispose()

        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()
        
        console.timeEnd('onChangeSkippingMethod@Computes') 
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log('')
    }

}