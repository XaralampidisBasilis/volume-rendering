import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../Utils/EventEmitter'
import Experience from '../Experience'
import VolumeMap from './Maps/VolumeMap'
import InterpolationMap from './Maps/InterpolationMap'
import ExtremaMap from './Maps/ExtremaMap'
import OccupancyMap from './Maps/OccupancyMap'
import IsotropicDistanceMap from './Maps/IsotropicDistanceMap'
import AnisotropicDistanceMap from './Maps/AnisotropicDistanceMap'
import ExtendedIsotropicDistanceMap from './Maps/ExtendedIsotropicDistanceMap'
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
        this.extendedIsotropicDistanceMap = new ExtendedIsotropicDistanceMap()
        this.extendedAnisotropicDistanceMap = new ExtendedAnisotropicDistanceMap()
        this.resolveDistanceMap()
    }

    resolveDistanceMap()
    {
        this.skippingMethod = this.configs.skippingMethod
        this.distanceMap = this.isotropicDistanceMap

        if (this.skippingMethod === 'anisotropicDistance')
            this.distanceMap = this.anisotropicDistanceMap
        
        if (this.skippingMethod === 'extendedIsotropicDistance')
            this.distanceMap = this.extendedIsotropicDistanceMap

        if (this.skippingMethod === 'extendedAnisotropicDistance')
            this.distanceMap = this.extendedAnisotropicDistanceMap
    }

    async start()
    {
        console.time('start@Computes') 

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.volumeMap.tensor.dispose()
        await tf.nextFrame()

        this.extremaMap.computeTensor()
        this.interpolationMap.computeTexture()
        this.interpolationMap.tensor.dispose()
        await tf.nextFrame()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        await tf.nextFrame()

        if (this.configs.boundingBoxEnabled) 
            this.occupancyMap.computeBoundingBox()

        this.occupancyMap.computeTexture()
        this.occupancyMap.tensor.dispose()
        await tf.nextFrame()

        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()
        await tf.nextFrame()

        console.timeEnd('start@Computes') 
        this.printResources()
    }

    async change(event)
    {
        if      (event.key === 'isosurfaceValue'    ) await this.onChangeIsosurfaceValue(event)
        else if (event.key === 'blockSize'          ) await this.onChangeBlockSize(event)
        else if (event.key === 'downscaleFactor'    ) await this.onChangeDownscaleFactor(event)
        else if (event.key === 'interpolationMethod') await this.onChangeInterpolationMethod(event)
        else if (event.key === 'skippingMethod'     ) await this.onChangeSkippingMethod(event)
    }

    async onChangeIsosurfaceValue(event)
    {
        console.time('onChangeIsosurfaceValue@Computes') 

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        if (this.configs.boundingBoxEnabled) 
            this.occupancyMap.computeBoundingBox()

        this.occupancyMap.updateTexture()
        this.occupancyMap.tensor.dispose()

        this.distanceMap.updateTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeIsosurfaceValue@Computes')
        this.printResources() 
    }

    async onChangeBlockSize(event)
    {
        console.time('onChangeBlockSize@Computes') 

        this.extremaMap.tensor.dispose()
        this.occupancyMap.texture.dispose()
        this.distanceMap.texture.dispose()
        await tf.nextFrame()

        this.interpolationMap.restoreTensor()
        this.extremaMap.computeTensor()
        this.interpolationMap.tensor.dispose()
        await tf.nextFrame()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        if (this.configs.boundingBoxEnabled) 
            this.occupancyMap.computeBoundingBox()

        this.occupancyMap.computeTexture()
        this.occupancyMap.tensor.dispose()
        await tf.nextFrame()

        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()
        await tf.nextFrame()

        console.timeEnd('onChangeBlockSize@Computes')
        this.printResources() 
    }

    async onChangeDownscaleFactor(event)
    {
        console.time('onChangeDownscaleFactor@Computes') 

        this.extremaMap.tensor.dispose()
        this.interpolationMap.texture.dispose()
        this.occupancyMap.texture.dispose()
        this.distanceMap.texture.dispose()
        await tf.nextFrame()

        this.volumeMap.computeTensor()
        this.interpolationMap.computeTensor()
        this.volumeMap.tensor.dispose()
        await tf.nextFrame()

        this.extremaMap.computeTensor()
        this.interpolationMap.computeTexture()
        this.interpolationMap.tensor.dispose()
        await tf.nextFrame()

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()
        await tf.nextFrame()

        if (this.configs.boundingBoxEnabled) 
            this.occupancyMap.computeBoundingBox()

        this.occupancyMap.computeTexture()
        this.occupancyMap.tensor.dispose()
        await tf.nextFrame()

        this.distanceMap.computeTexture()
        this.distanceMap.tensor.dispose()
        await tf.nextFrame()

        console.timeEnd('onChangeDownscaleFactor@Computes') 
        this.printResources()
    }

    async onChangeInterpolationMethod(event)
    {
        console.time('onChangeInterpolationMethod@Computes') 

        this.occupancyMap.computeTensor()
        this.distanceMap.computeTensor()

        if (this.configs.boundingBoxEnabled) 
            this.occupancyMap.computeBoundingBox()

        this.occupancyMap.updateTexture()
        this.occupancyMap.tensor.dispose()

        this.distanceMap.updateTexture()
        this.distanceMap.tensor.dispose()

        console.timeEnd('onChangeInterpolationMethod@Computes') 
        this.printResources()
    }

    async onChangeSkippingMethod(event)
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
        console.log('')
    }

    destroy()
    {
        this.volumeMap.dispose()
        this.interpolationMap.dispose()
        this.extremaMap.dispose()
        this.occupancyMap.dispose()
        this.isotropicDistanceMap.dispose()
        this.anisotropicDistanceMap.dispose()
        this.extendedAnisotropicDistanceMap.dispose()

        this.volumeMap = null
        this.interpolationMap = null
        this.extremaMap = null
        this.occupancyMap = null
        this.isotropicDistanceMap = null
        this.anisotropicDistanceMap = null
        this.extendedAnisotropicDistanceMap = null

        this.experience = null
        this.renderer = null
        this.configs = null
        this.resources = null

        instance = null

        console.log('Computes destroyed')
    }
    
    printResources()
    {
        console.log(`Num of tensors: ${tf.memory().numTensors}, Num of textures: ${this.renderer.instance.info.memory.textures}`)
        console.log(``)
    }
}