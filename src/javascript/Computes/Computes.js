import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../Utils/EventEmitter'
import Experience from '../Experience'
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

        // singleton
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

        this.interpolationMap.compute()
        this.extremaMap.compute()
        this.occupancyMap.compute()
        this.distanceMap?.compute()
        
        console.timeEnd('startComputes') 
    }

    change(event)
    {
        if (event.key === 'isosurfaceValue'    ) this.onChangeIsosurfaceValue(event)
        if (event.key === 'blockSize'          ) this.onChangeBlockSize(event)
        if (event.key === 'interpolationMethod') this.onChangeInterpolationMethod(event)
        if (event.key === 'skippingMethod'     ) this.onChangeSkippingMethod(event)
    }

    onChangeIsosurfaceValue(event)
    {
        this.occupancyMap.dispose()
        this.occupancyMap.compute()

        this.distanceMap?.dispose()
        this.distanceMap?.compute()
    }

    onChangeBlockSize(event)
    {
        this.extremaMap.dispose()
        this.extremaMap.compute()

        this.occupancyMap.dispose()
        this.occupancyMap.compute()
        
        this.distanceMap?.dispose()
        this.distanceMap?.compute()
    }

    onChangeInterpolationMethod(event)
    {
        this.extremaMap.dispose()
        this.extremaMap.compute()
        
        this.occupancyMap.dispose()
        this.occupancyMap.compute()

        this.distanceMap?.dispose()
        this.distanceMap?.compute()
    }

    onChangeSkippingMethod(event)
    {
        this.distanceMap?.dispose()
        this.distanceMap = null

        if (this.skippingMethod.endsWith('DistanceMap'))
        {
            this.distanceMap = this[this.skippingMethod]
            this.distanceMap.compute()
        }

        if (this.skippingMethod === 'occupancyMap')
        {
            this.occupancyMap.dispose()
            this.occupancyMap.compute()
        }
    }

}