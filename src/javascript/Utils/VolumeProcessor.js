import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from './TensorUtils'
import EventEmitter from './EventEmitter'
import { timeit } from './timeit'

export default class VolumeProcessor extends EventEmitter
{
    constructor(volume, renderer)
    {
        super()

        this.renderer = renderer
        this.volume = volume
        this.parameters = {}
        this.computes = {}
        this.textures = {}

        this.setVolumeParameters()
        timeit(() => this.computeIntensityMap(), 'computeIntensityMap')
        timeit(() => this.computeGradientMap(), 'computeGradientMap')

        // timeit(() => this.computeTaylorMap(), 'computeTaylorMap')
        // timeit(() => this.computeOccupancyMap(0, 10), 'computeOccupancyMap')
        // timeit(() => this.computeOccupancyAtlas(), 'computeOccupancyAtlas')
        // timeit(() => this.computeOccupancyDistanceMap(0, 2, 255), 'computeOccupancyDistanceMap')
        // timeit(() => this.computeExtremaMap(10), 'computeExtremaMap')
        // timeit(() => this.computeExtremaDistanceMap(2, 40), 'computeExtremaDistanceMap')
    }

    setVolumeParameters()
    {
        this.parameters.volume = {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map((x) => 1 / x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            shape        : this.volume.dimensions.toReversed().concat(1).concat(1),
        }
    }

    // compute functions

    computeIntensityMap()
    {
        if (this.computes.intensityMap) 
            this.disposeIntensityMap()

        this.parameters.intensityMap = this.parameters.volume
        this.computes.intensityMap = tf.tensor5d(this.volume.data, this.parameters.intensityMap.shape,'float32')

        console.log(this.parameters.intensityMap)
        console.log(this.computes.intensityMap.dataSync())
    }

    computeGradientMap()
    {
        if (this.computes.gradientMap) 
            this.disposeGradientMap()

        this.parameters.gradientMap = this.parameters.volume
        this.computes.gradientMap = TensorUtils.gradients3d(this.computes.intensityMap, this.parameters.volume.spacing)

        console.log(this.parameters.gradientMap)
        console.log(this.computes.gradientMap.dataSync())
    }
 
    computeTaylorMap()
    {
        if (!this.computes.intensityMap) 
            this.computeIntensityMap()

        if (!this.computes.gradientMap) 
            this.computeGradientMap()

        if (this.computes.taylorMap) 
            this.disposeTaylorMap()

        this.parameters.taylorMap = this.parameters.volume
        this.computes.taylorMap = tf.concat([this.computes.intensityMap, this.computes.gradientMap], 3)
        this.disposeIntensityMap()
        this.disposeGradientMap()

        console.log(this.parameters.taylorMap)
        console.log(this.computes.taylorMap.dataSync())
    }

    computeOccupancyMap(threshold, division)
    {
        if (this.computes.occupancyMap) 
            this.computes.occupancyMap.dispose()

        this.computes.occupancyMap = TensorUtils.occupancyMap(this.computes.intensityMap, threshold, division)
        this.parameters.occupancyMap = {}
        this.parameters.occupancyMap.threshold = threshold
        this.parameters.occupancyMap.division = division
        this.parameters.occupancyMap.dimensions = new THREE.Vector3().fromArray(this.computes.occupancyMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.occupancyMap.division)
        this.parameters.occupancyMap.size = new THREE.Vector3().copy(this.parameters.occupancyMap.dimensions).multiply(this.parameters.occupancyMap.spacing)
        this.parameters.occupancyMap.numBlocks = this.parameters.occupancyMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)

        console.log(this.parameters.occupancyMap)
        console.log(this.computes.occupancyMap.dataSync())
    }

    computeOccupancyAtlas(threshold, division)
    {
        if (this.computes.occupancyAtlas) 
            this.computes.occupancyAtlas.dispose()

        this.computes.occupancyAtlas = TensorUtils.occupancyAtlas(this.computes.intensityMap, threshold, division)

        console.log(this.parameters.occupancyAtlas)
        console.log(this.computes.occupancyAtlas.dataSync())
    }

    computeOccupancyDistanceMap(threshold, division, maxDistance)
    {
        if (this.computes.occupancyDistanceMap) 
            this.computes.occupancyDistanceMap.dispose()

        this.computes.occupancyDistanceMap = TensorUtils.occupancyDistanceMap(this.computes.intensityMap, threshold, division, maxDistance)
        this.parameters.occupancyDistanceMap = {}
        this.parameters.occupancyDistanceMap.threshold = threshold
        this.parameters.occupancyDistanceMap.division = division
        this.parameters.occupancyDistanceMap.maxDistance = maxDistance
        this.parameters.occupancyDistanceMap.dimensions = new THREE.Vector3().fromArray(this.computes.occupancyDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.occupancyDistanceMap.division)
        this.parameters.occupancyDistanceMap.size = new THREE.Vector3().copy(this.parameters.occupancyDistanceMap.dimensions).multiply(this.parameters.occupancyDistanceMap.spacing)
        this.parameters.occupancyDistanceMap.numBlocks = this.parameters.occupancyDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
    
        console.log(this.parameters.occupancyDistanceMap)
        console.log(this.computes.occupancyDistanceMap.dataSync())
    }

    computeExtremaMap(division)
    {
        if (this.computes.extremaMap) 
            this.computes.extremaMap.dispose()

        this.computes.extremaMap = TensorUtils.extremaMap(this.computes.intensityMap, division)
        this.parameters.extremaMap = {}
        this.parameters.extremaMap.division = division
        this.parameters.extremaMap.dimensions = new THREE.Vector3().fromArray(this.computes.extremaMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.extremaMap.division)
        this.parameters.extremaMap.size = new THREE.Vector3().copy(this.parameters.extremaMap.dimensions).multiply(this.parameters.extremaMap.spacing)
        this.parameters.extremaMap.numBlocks = this.parameters.extremaMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)

        console.log(this.parameters.extremaMap)
        console.log(this.computes.extremaMap.dataSync())
    }

    computeExtremaDistanceMap(division, maxDistance)
    {
        if (this.computes.extremaDistanceMap) 
            this.computes.extremaDistanceMap.dispose()

        this.computes.extremaDistanceMap = TensorUtils.extremaDistanceMap(this.computes.intensityMap, division, maxDistance)
        this.parameters.extremaDistanceMap = {}
        this.parameters.extremaDistanceMap.division = division
        this.parameters.extremaDistanceMap.maxDistance = maxDistance
        this.parameters.extremaDistanceMap.dimensions = new THREE.Vector3().fromArray(this.computes.extremaDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.extremaDistanceMap.division)
        this.parameters.extremaDistanceMap.size = new THREE.Vector3().copy(this.parameters.extremaDistanceMap.dimensions).multiply(this.parameters.extremaDistanceMap.spacing)
        this.parameters.extremaDistanceMap.numBlocks = this.parameters.extremaDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        
        console.log(this.parameters.extremaDistanceMap)
        console.log(this.computes.extremaDistanceMap.dataSync())
    }

    // 

    resizeIntensityMap()
    {
        if (!this.computes.intensityMap) 
            this.computeIntensityMap()

        const intensityMap = TensorUtils.resizeLinear3d(this.computes.intensityMap, radius)
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap

        console.log(this.parameters.intensityMap)
        console.log(this.computes.intensityMap.dataSync())
    }

    smoothIntensityMap(radius)
    {
        if (!this.computes.intensityMap) 
            this.computeIntensityMap()

        const intensityMap = TensorUtils.smoothing3d(this.computes.intensityMap, radius)
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap

        console.log(this.parameters.intensityMap)
        console.log(this.computes.intensityMap.dataSync())
    }

    quantizeIntensityMap()
    {
        if (!this.computes.intensityMap) 
            this.computeIntensityMap()
        
        const [intensityMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.intensityMap) 
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap
        this.parameters.intensityMap.minValue = minValue
        this.parameters.intensityMap.maxValue = maxValue  

        console.log(this.parameters.intensityMap)
        console.log(this.computes.intensityMap.dataSync())
    }

    quantizeGradientMap()
    {
        if (!this.computes.gradientMap) 
            this.computeGradientMap()
    
        const [gradientMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.gradientMap) 
        this.computes.gradientMap.dispose()
        this.computes.gradientMap = gradientMap
        this.parameters.gradientMap.minValue = minValue
        this.parameters.gradientMap.maxValue = maxValue 

        console.log(this.parameters.gradientMap)
        console.log(this.computes.gradientMap.dataSync())
    }

    quantizeTaylorMap()
    {
        if (!this.computes.taylorMap) 
            this.computeTaylorMap()

        const [taylorMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.taylorMap) 
        this.computes.taylorMap.dispose()
        this.computes.taylorMap = taylorMap
        this.parameters.taylorMap.minValue = minValue
        this.parameters.taylorMap.maxValue = maxValue 

        console.log(this.parameters.taylorMap)
        console.log(this.computes.taylorMap.dataSync())
    }

    // texture generators

    generateIntensityMap()
    {
        if (this.textures.intensityMap) 
            this.textures.intensityMap.dispose()

        this.textures.intensityMap = new THREE.Data3DTexture(
            this.computes.intensityMap.dataSync(), 
            ...this.parameters.intensityMap.dimensions.toArray())
        this.textures.intensityMap.format = THREE.RedFormat
        this.textures.intensityMap.type = THREE.FloatType     
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.generateMipmaps = false
        this.textures.intensityMap.needsUpdate = true   
        this.computes.intensityMap.dispose()

        return this.textures.intensityMap
    }

    generateGradientMap()
    {
        // textures
        if (this.textures.gradientMap) 
            this.textures.gradientMap.dispose()

        this.textures.gradientMap = new THREE.Data3DTexture(
            this.computes.gradientMap.dataSync(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.gradientMap.format = THREE.RGBFormat
        this.textures.gradientMap.type = THREE.FloatType     
        this.textures.gradientMap.minFilter = THREE.LinearFilter
        this.textures.gradientMap.magFilter = THREE.LinearFilter
        this.textures.gradientMap.generateMipmaps = false
        this.textures.gradientMap.needsUpdate = true   
        this.computes.gradientMap.dispose()

        return this.textures.gradientMap
    }

    generateTaylorMap()
    {
        if (this.textures.taylorMap) 
            this.textures.taylorMap.dispose()

        this.textures.taylorMap = new THREE.Data3DTexture(
            this.computes.taylorMap.dataSync(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.taylorMap.format = THREE.RGBAFormat
        this.textures.taylorMap.type = THREE.FloatType     
        this.textures.taylorMap.minFilter = THREE.LinearFilter
        this.textures.taylorMap.magFilter = THREE.LinearFilter
        this.textures.taylorMap.generateMipmaps = false
        this.textures.taylorMap.needsUpdate = true
        this.computes.taylorMap.dispose()

        return this.textures.taylorMap
    }

    generateQuantizedIntensityMap()
    {
        if (this.textures.intensityMap) 
            this.textures.intensityMap.dispose()

        this.textures.intensityMap = new THREE.Data3DTexture(
            this.computes.intensityMap.dataSync(), 
            ...this.parameters.intensityMap.dimensions.toArray())
        this.textures.intensityMap.format = THREE.RedFormat
        this.textures.intensityMap.type = THREE.UnsignedByteType     
        this.textures.intensityMap.minFilter = THREE.LinearFilter
        this.textures.intensityMap.magFilter = THREE.LinearFilter
        this.textures.intensityMap.generateMipmaps = false
        this.textures.intensityMap.needsUpdate = true   
        this.computes.intensityMap.dispose()

        return this.textures.intensityMap
    }

    generateQuantizedGradientMap()
    {
        // textures
        if (this.textures.gradientMap) 
            this.textures.gradientMap.dispose()

        this.textures.gradientMap = new THREE.Data3DTexture(
            this.computes.gradientMap.dataSync(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.gradientMap.format = THREE.RGBFormat
        this.textures.gradientMap.type = THREE.UnsignedByteType     
        this.textures.gradientMap.minFilter = THREE.LinearFilter
        this.textures.gradientMap.magFilter = THREE.LinearFilter
        this.textures.gradientMap.generateMipmaps = false
        this.textures.gradientMap.needsUpdate = true   
        this.computes.gradientMap.dispose()

        return this.textures.gradientMap
    }

    generateQuantizedTaylorMap()
    {
        if (this.textures.taylorMap) 
            this.textures.taylorMap.dispose()

        this.textures.taylorMap = new THREE.Data3DTexture(
            this.computes.taylorMap.dataSync(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.taylorMap.format = THREE.RGBAFormat
        this.textures.taylorMap.type = THREE.UnsignedByteType     
        this.textures.taylorMap.minFilter = THREE.LinearFilter
        this.textures.taylorMap.magFilter = THREE.LinearFilter
        this.textures.taylorMap.generateMipmaps = false
        this.textures.taylorMap.needsUpdate = true
        this.computes.taylorMap.dispose()

        return this.textures.taylorMap
    }

    generateOccupancyMap()
    {
        if (this.textures.occupancyMap) 
            this.textures.occupancyMap.dispose()

        this.textures.occupancyMap = new THREE.Data3DTexture(
            this.computes.occupancyMap.dataSync(), 
            ...this.parameters.occupancyMap.dimensions.toArray())
        this.textures.occupancyMap.format = THREE.RedFormat
        this.textures.occupancyMap.type = THREE.UnsignedByteType     
        this.textures.occupancyMap.minFilter = THREE.LinearFilter
        this.textures.occupancyMap.magFilter = THREE.LinearFilter
        this.textures.occupancyMap.generateMipmaps = false
        this.textures.occupancyMap.needsUpdate = true  
        this.computes.occupancyMap.dispose() 

        return this.textures.occupancyMap
    }

    generateOccupancyAtlas()
    {
        if (this.textures.occupancyAtlas) 
            this.textures.occupancyAtlas.dispose()

        this.textures.occupancyAtlas = new THREE.Data3DTexture(
            this.computes.occupancyAtlas.dataSync(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.occupancyAtlas.format = THREE.RedFormat
        this.textures.occupancyAtlas.type = THREE.UnsignedByteType     
        this.textures.occupancyAtlas.minFilter = THREE.LinearFilter
        this.textures.occupancyAtlas.magFilter = THREE.LinearFilter
        this.textures.occupancyAtlas.generateMipmaps = false
        this.textures.occupancyAtlas.needsUpdate = true   
        this.computes.occupancyAtlas.dispose() 

        return this.textures.occupancyAtlas
    }

    generateOccupancyDistanceMap()
    {
        if (this.textures.occupancyDistanceMap) 
            this.textures.occupancyDistanceMap.dispose()

        this.textures.occupancyDistanceMap = new THREE.Data3DTexture(
            this.computes.occupancyDistanceMap.dataSync(), 
            ...this.parameters.occupancyDistanceMap.dimensions.toArray())
        this.textures.occupancyDistanceMap.format = THREE.RedFormat
        this.textures.occupancyDistanceMap.type = THREE.UnsignedByteType     
        this.textures.occupancyDistanceMap.minFilter = THREE.LinearFilter
        this.textures.occupancyDistanceMap.magFilter = THREE.LinearFilter
        this.textures.occupancyDistanceMap.generateMipmaps = false
        this.textures.occupancyDistanceMap.needsUpdate = true   
        this.computes.occupancyDistanceMap.dispose() 

        return this.textures.occupancyDistanceMap
    }

    generateExtremaMap()
    {
        if (this.textures.extremaMap) 
            this.textures.extremaMap.dispose()

        this.textures.extremaMap = new THREE.Data3DTexture(
            this.computes.extremaMap.data(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.extremaMap.format = THREE.RGFormat
        this.textures.extremaMap.type = THREE.FloatType     
        this.textures.extremaMap.minFilter = THREE.LinearFilter
        this.textures.extremaMap.magFilter = THREE.LinearFilter
        this.textures.extremaMap.generateMipmaps = false
        this.textures.extremaMap.needsUpdate = true  
        this.computes.extremaMap.dispose()
        
        return this.textures.extremaMap
    }

    generateExtremaDistanceMap()
    {
        if (this.textures.extremaDistanceMap) 
            this.textures.extremaDistanceMap.dispose()

        this.textures.extremaDistanceMap = new THREE.Data3DTexture(
            this.computes.extremaDistanceMap.data(), 
            ...this.parameters.volume.dimensions.toArray())
        this.textures.extremaDistanceMap.format = THREE.RedFormat
        this.textures.extremaDistanceMap.type = THREE.FloatType     
        this.textures.extremaDistanceMap.minFilter = THREE.LinearFilter
        this.textures.extremaDistanceMap.magFilter = THREE.LinearFilter
        this.textures.extremaDistanceMap.generateMipmaps = false
        this.textures.extremaDistanceMap.needsUpdate = true   
        this.computes.extremaDistanceMap.dispose()
        
        return this.textures.extremaDistanceMap
    }

    // dispose functions

    disposeIntensityMap()
    { 
        this.parameters.intensityMap = {}

        if (this.computes.intensityMap) 
            this.computes.intensityMap.dispose()   

        if (this.textures.intensityMap) 
            this.textures.intensityMap.dispose()   
    }

    disposeGradientMap()
    { 
        this.parameters.gradientMap = {}

        if (this.computes.gradientMap) 
            this.computes.gradientMap.dispose()   

        if (this.textures.gradientMap) 
            this.textures.gradientMap.dispose()   
    }

    disposeTaylorMap()
    { 
        this.parameters.taylorMap = {}

        if (this.computes.taylorMap) 
            this.computes.taylorMap.dispose()   

        if (this.textures.taylorMap) 
            this.textures.taylorMap.dispose()   
    }

    disposeOccupancyMap()
    { 
        this.parameters.occupancyMap = {}

        if (this.computes.occupancyMap) 
            this.computes.occupancyMap.dispose()   

        if (this.textures.occupancyMap) 
            this.textures.occupancyMap.dispose()   
    }

    disposeOccupancyAtlas()
    { 
        this.parameters.occupancyAtlas = {}

        if (this.computes.occupancyAtlas) 
            this.computes.occupancyAtlas.dispose()   

        if (this.textures.occupancyAtlas) 
            this.textures.occupancyAtlas.dispose()   
    }

    disposeOccupancyDistanceMap()
    { 
        this.parameters.occupancyDistanceMap = {}

        if (this.computes.occupancyDistanceMap) 
            this.computes.occupancyDistanceMap.dispose()   

        if (this.textures.occupancyDistanceMap) 
            this.textures.occupancyDistanceMap.dispose()   
    }

    disposeExtremaMap()
    { 
        this.parameters.extremaMap = {}

        if (this.computes.extremaMap) 
            this.computes.extremaMap.dispose()   

        if (this.textures.extremaMap) 
            this.textures.extremaMap.dispose()   
    }

    disposeExtremaDistanceMap()
    { 
        this.parameters.extremaDistanceMap = {}

        if (this.computes.extremaDistanceMap) 
            this.computes.extremaDistanceMap.dispose()   

        if (this.textures.extremaDistanceMap) 
            this.textures.extremaDistanceMap.dispose()   
    }
}