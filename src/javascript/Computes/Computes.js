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
        this.configs = this.experience.configs
        this.resources = this.experience.resources
        this.skippingMethod = this.configs.skippingMethod
        
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
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.interpolationMap.computeTexture()
        this.occupancyMap.computeTexture()
        this.distanceMap.computeTexture()

        this.volumeMap.tensor.dispose()
        this.interpolationMap.tensor.dispose()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()

        console.timeEnd('start@Computes') 
        console.log('')
    }

    change(event)
    {
        if (event.key === 'isosurfaceValue'    ) this.onChangeIsosurfaceValue(event)
        if (event.key === 'blockSize'          ) this.onChangeBlockSize(event)
        if (event.key === 'downscaleFactor'    ) this.onChangeDownscaleFactor(event)
        if (event.key === 'interpolationMethod') this.onChangeInterpolationMethod(event)
        if (event.key === 'skippingMethod'     ) this.onChangeSkippingMethod(event)
    }

    onChangeIsosurfaceValue(event)
    {
        console.time('onChangeIsosurfaceValue@Computes') 
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        this.occupancyMap.updateTexture()
        this.distanceMap.updateTexture()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()
        console.timeEnd('onChangeIsosurfaceValue@Computes')
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
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.occupancyMap.computeTexture()
        this.distanceMap.computeTexture()

        this.interpolationMap.tensor.dispose()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeBlockSize@Computes')
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
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        this.interpolationMap.computeTexture()
        this.occupancyMap.computeTexture()
        this.distanceMap.computeTexture()

        this.volumeMap.tensor.dispose()
        this.interpolationMap.tensor.dispose()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeDownscaleFactor@Computes') 
        console.log('')
    }

    onChangeInterpolationMethod(event)
    {
        console.time('onChangeInterpolationMethod@Computes') 
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        this.occupancyMap.updateTexture()
        this.distanceMap.updateTexture()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()
        console.timeEnd('onChangeInterpolationMethod@Computes') 
        console.log('')
    }

    onChangeSkippingMethod(event)
    {
        console.time('onChangeSkippingMethod@Computes') 
        this.distanceMap.texture.dispose()
        this.resolveDistanceMap()
        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        this.distanceMap.computeTexture()
        this.occupancyMap.tensor.dispose()
        this.distanceMap.tensor.dispose()
        console.timeEnd('onChangeSkippingMethod@Computes') 
        console.log('')
    }

}