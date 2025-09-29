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
        
        this.distanceMap = this.skippingMethod.endsWith('DistanceMap') ? this[this.skippingMethod] : null
    }

    start()
    {
        console.time('startComputes') 

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap?.computeTensor()

        this.volumeMap.tensor.dispose()

        console.timeEnd('startComputes') 
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
        console.time('onChangeIsosurfaceValueComputes') 

        this.occupancyMap.computeTensor()
        this.distanceMap?.computeTensor()

        console.timeEnd('onChangeIsosurfaceValueComputes') 
    }

    onChangeBlockSize(event)
    {
        console.time('onChangeBlockSizeComputes') 

        this.interpolationMap.restoreTensor()
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap?.computeTensor()

        this.interpolationMap.tensor.dispose()

        console.timeEnd('onChangeBlockSizeComputes') 
    }

    onChangeDownscaleFactor(event)
    {
        console.time('onChangeDownscaleFactorComputes') 

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap?.computeTensor()

        this.volumeMap.tensor.dispose()

        console.timeEnd('onChangeDownscaleFactorComputes') 
    }

    onChangeInterpolationMethod(event)
    {
        console.time('onChangeInterpolationMethodComputes') 

        this.interpolationMap.restoreTensor()
        this.extremaMap.computeTensor()
        this.occupancyMap.computeTensor()
        this.distanceMap?.computeTensor()

        this.interpolationMap.tensor.dispose()

        console.timeEnd('onChangeInterpolationMethodComputes') 
    }

    onChangeSkippingMethod(event)
    {
        console.time('onChangeSkippingMethodComputes') 

        this.distanceMap?.dispose()
        this.distanceMap = null

        if (this.skippingMethod.endsWith('DistanceMap'))
        {
            this.distanceMap = this[this.skippingMethod]
            this.distanceMap.computeTensor()
        }

        if (this.skippingMethod === 'occupancyMap')
        {
            this.occupancyMap.computeTensor()
        }
        console.timeEnd('onChangeSkippingMethodComputes') 
    }

}