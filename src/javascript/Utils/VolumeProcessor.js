import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from './TensorUtils'
import EventEmitter from './EventEmitter'
import { timeit } from './timeit'


/*
    Currently handles only spatial volume data without temporal information
*/
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
        this.setParameters()

        timeit(() => this.computeIntensityMap(), 'computeIntensityMap')
        // timeit(() => this.computeGradientMap(), 'computeGradientMap')
        // timeit(() => this.computeTaylorMap(), 'computeTaylorMap')
        // timeit(() => this.computeOccupancyMap(0, 4), 'computeOccupancyMap')
        // timeit(() => this.computeOccupancyMipmaps(0, 4), 'computeOccupancyAtlas')
        // timeit(() => this.computeOccupancyDistanceMap(0, 2, 255), 'computeOccupancyDistanceMap')
        timeit(() => this.computeOccupancyBoundingBox(0), 'computeOccupancyBoundingBox')
        // timeit(() => this.computeExtremaMap(4), 'computeExtremaMap')
        // timeit(() => this.computeExtremaDistanceMap(4, 40), 'computeExtremaDistanceMap')
        
        // timeit(() => this.downscaleIntensityMap(2), 'rescaleIntensityMap')
        // timeit(() => this.smoothIntensityMap(1), 'smoothIntensityMap')
        // timeit(() => this.quantizeIntensityMap(256), 'quantizeIntensityMap')
        // timeit(() => this.quantizeGradientMap(256), 'quantizeGradientMap')
        // timeit(() => this.quantizeTaylorMap(256), 'quantizeTaylorMap')
    }

    setParameters()
    {
        this.parameters.volume = {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map((x) => 1 / x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            shape        : this.volume.dimensions.toReversed().concat(1),
        }
    }

    // compute functions

    computeIntensityMap()
    {
        if (this.computes.intensityMap) this.disposeMap('intensityMap')

        this.parameters.intensityMap = this.parameters.volume
        this.computes.intensityMap = tf.tensor4d(this.volume.data, this.parameters.intensityMap.shape,'float32')
        // console.log('intensityMap', this.parameters.intensityMap, this.computes.intensityMap.dataSync())
    }

    computeGradientMap()
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        if (this.computes.gradientMap) this.disposeMap('gradientMap')

        this.computes.gradientMap = TensorUtils.gradients3d(this.computes.intensityMap, this.parameters.volume.spacing)
        this.parameters.gradientMap = this.parameters.volume
        this.parameters.gradientMap.shape = this.computes.gradientMap.shape
        // console.log('gradientMap', this.parameters.gradientMap, this.computes.gradientMap.dataSync())
    }
 
    computeTaylorMap()
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        if (!this.computes.gradientMap) throw new Error(`quantizeIntensityMap: gradientMap is not computed`)
        if (this.computes.taylorMap)  this.disposeMap('taylorMap')

        this.computes.taylorMap = tf.concat([this.computes.intensityMap, this.computes.gradientMap], 3)
        this.parameters.taylorMap = this.parameters.volume
        this.parameters.taylorMap.shape = this.computes.taylorMap.shape
        // console.log('taylorMap', this.parameters.taylorMap, this.computes.taylorMap.dataSync())
    }

    computeOccupancyMap(threshold, division)
    {
        if (this.computes.occupancyMap) this.disposeMap('occupancyMap')
        this.computes.occupancyMap = TensorUtils.occupancyMap(this.computes.intensityMap, threshold, division)
        this.parameters.occupancyMap = {}
        this.parameters.occupancyMap.threshold = threshold
        this.parameters.occupancyMap.division = division
        this.parameters.occupancyMap.dimensions = new THREE.Vector3().fromArray(this.computes.occupancyMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(division)
        this.parameters.occupancyMap.size = new THREE.Vector3().copy(this.parameters.occupancyMap.dimensions).multiply(this.parameters.occupancyMap.spacing)
        this.parameters.occupancyMap.numBlocks = this.parameters.occupancyMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        this.parameters.occupancyMap.shape = this.computes.occupancyMap.shape
        // console.log('occupancyMap', this.parameters.occupancyMap, this.computes.occupancyMap.dataSync())
    }

    computeOccupancyMipmaps(threshold, division)
    {
        if (!this.computes.intensityMap) throw new Error(`computeOccupancyAtlas: intensityMap is not computed`)
        if (this.computes.occupancyMipmaps) this.disposeMap('occupancyMipmaps')
        const occupancyMipmaps = TensorUtils.occupancyMipmaps(this.computes.intensityMap, threshold, division)
        const compactOccupancyMipmaps = TensorUtils.compactMipmaps(occupancyMipmaps)
        this.computes.occupancyMipmaps = compactOccupancyMipmaps
        this.parameters.occupancyMipmaps = {}
        this.parameters.occupancyMipmaps.threshold = threshold
        this.parameters.occupancyMipmaps.division = division
        this.parameters.occupancyMipmaps.levels = occupancyMipmaps.length
        this.parameters.occupancyMipmaps.dimensions = new THREE.Vector3().fromArray(compactOccupancyMipmaps.shape.slice(0, 3).toReversed())
        this.parameters.occupancyMipmaps.shape = compactOccupancyMipmaps.shape
        this.parameters.occupancyMipmaps.dimensions0 = new THREE.Vector3().fromArray(occupancyMipmaps[0].shape.slice(0, 3).toReversed())
        this.parameters.occupancyMipmaps.spacing0 = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(division)
        this.parameters.occupancyMipmaps.size0 = new THREE.Vector3().copy(this.parameters.occupancyMipmaps.dimensions0).multiply(this.parameters.occupancyMipmaps.spacing0)
        // console.log('occupancyMipmaps', this.parameters.occupancyMipmaps, this.computes.occupancyMipmaps.dataSync())
    }

    computeOccupancyDistanceMap(threshold, division, maxDistance)
    {
        if (!this.computes.intensityMap) throw new Error(`computeOccupancyDistanceMap: intensityMap is not computed`)
        if (this.computes.occupancyDistanceMap) this.disposeMap('occupancyDistanceMap')
        this.computes.occupancyDistanceMap = TensorUtils.occupancyDistanceMap(this.computes.intensityMap, threshold, division, maxDistance)
        this.parameters.occupancyDistanceMap = {}
        this.parameters.occupancyDistanceMap.threshold = threshold
        this.parameters.occupancyDistanceMap.division = division
        this.parameters.occupancyDistanceMap.maxDistance = maxDistance
        this.parameters.occupancyDistanceMap.dimensions = new THREE.Vector3().fromArray(this.computes.occupancyDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.occupancyDistanceMap.division)
        this.parameters.occupancyDistanceMap.size = new THREE.Vector3().copy(this.parameters.occupancyDistanceMap.dimensions).multiply(this.parameters.occupancyDistanceMap.spacing)
        this.parameters.occupancyDistanceMap.numBlocks = this.parameters.occupancyDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        this.parameters.occupancyDistanceMap.shape = this.computes.occupancyDistanceMap.shape
        // console.log('occupancyDistanceMap', this.parameters.occupancyDistanceMap, this.computes.occupancyDistanceMap.dataSync())
    }

    computeOccupancyBoundingBox(threshold)
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        const boundingBox = TensorUtils.occupancyBoundingBox(this.computes.intensityMap, threshold)
        this.parameters.occupancyBoundingBox = {}
        this.parameters.occupancyBoundingBox.threshold = threshold
        this.parameters.occupancyBoundingBox.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
        this.parameters.occupancyBoundingBox.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
        console.log('occupancyBoundingBox', this.parameters.occupancyBoundingBox)
    }

    computeExtremaMap(division)
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        if (this.computes.extremaMap) this.disposeMap('extremaMap')
        this.computes.extremaMap = TensorUtils.extremaMap(this.computes.intensityMap, division)
        this.parameters.extremaMap = {}
        this.parameters.extremaMap.division = division
        this.parameters.extremaMap.dimensions = new THREE.Vector3().fromArray(this.computes.extremaMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(division)
        this.parameters.extremaMap.size = new THREE.Vector3().copy(this.parameters.extremaMap.dimensions).multiply(this.parameters.extremaMap.spacing)
        this.parameters.extremaMap.numBlocks = this.parameters.extremaMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        this.parameters.extremaMap.shape = this.computes.extremaMap.shape
        // console.log('extremaMap', this.parameters.extremaMap, this.computes.extremaMap.dataSync())
    }

    computeExtremaDistanceMap(division, maxDistance)
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        if (this.computes.extremaDistanceMap) this.disposeMap('extremaDistanceMap')
        this.computes.extremaDistanceMap = TensorUtils.extremaDistanceMap(this.computes.intensityMap, division, maxDistance)
        this.parameters.extremaDistanceMap = {}
        this.parameters.extremaDistanceMap.division = division
        this.parameters.extremaDistanceMap.maxDistance = maxDistance
        this.parameters.extremaDistanceMap.dimensions = new THREE.Vector3().fromArray(this.computes.extremaDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(division)
        this.parameters.extremaDistanceMap.size = new THREE.Vector3().copy(this.parameters.extremaDistanceMap.dimensions).multiply(this.parameters.extremaDistanceMap.spacing)
        this.parameters.extremaDistanceMap.numBlocks = this.parameters.extremaDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        this.parameters.extremaDistanceMap.shape = this.computes.extremaDistanceMap.shape
        // console.log('extremaDistanceMap', this.parameters.extremaDistanceMap, this.computes.extremaDistanceMap.dataSync())
    }

    // alter functions

    downscaleIntensityMap(scale)
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`);
        const intensityMap = TensorUtils.downscale3d(this.computes.intensityMap, scale)
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap
        this.parameters.intensityMap.downScale = scale
        this.parameters.intensityMap.dimensions = new THREE.Vector3().fromArray(this.computes.intensityMap.shape.slice(0, 3).toReversed())
        this.parameters.intensityMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(scale)
        this.parameters.intensityMap.size = new THREE.Vector3().copy(this.parameters.intensityMap.dimensions).multiply(this.parameters.intensityMap.spacing)
        this.parameters.intensityMap.numBlocks = this.parameters.intensityMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        this.parameters.intensityMap.shape = this.computes.intensityMap.shape
        // console.log('downscaledIntensityMap', this.parameters.intensityMap, this.computes.intensityMap.dataSync())
    }

    smoothIntensityMap(radius)
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`);
        const intensityMap = TensorUtils.smooth3d(this.computes.intensityMap, radius)
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap
        this.parameters.intensityMap.smoothingRadius = radius
        // console.log('smoothedIntensityMap', this.parameters.intensityMap, this.computes.intensityMap.dataSync())
    }

    normalizeIntensityMap()
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        const [intensityMap, minValue, maxValue] = TensorUtils.normalize3d(this.computes.intensityMap) 
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap
        this.parameters.intensityMap.minValue = minValue
        this.parameters.intensityMap.maxValue = maxValue  
        // console.log('normalizedIntensityMap', this.parameters.intensityMap, this.computes.intensityMap.dataSync())
    }

    quantizeIntensityMap()
    {
        if (!this.computes.intensityMap) throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        const [intensityMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.intensityMap) 
        this.computes.intensityMap.dispose()
        this.computes.intensityMap = intensityMap
        this.parameters.intensityMap.minValue = minValue
        this.parameters.intensityMap.maxValue = maxValue  
        // console.log('quantizedIntensityMap', this.parameters.intensityMap, this.computes.intensityMap.dataSync())
    }

    quantizeGradientMap()
    {
        if (!this.computes.gradientMap) throw new Error(`quantizeGradientMap: gradientMap is not computed`)
        const [gradientMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.gradientMap) 
        this.computes.gradientMap.dispose()
        this.computes.gradientMap = gradientMap
        this.parameters.gradientMap.minValue = new THREE.Vector3().fromArray(minValue)
        this.parameters.gradientMap.maxValue = new THREE.Vector3().fromArray(maxValue) 
        // console.log('quantizedGradientMap', this.parameters.gradientMap, this.computes.gradientMap.dataSync())
    }

    quantizeTaylorMap()
    {
        if (!this.computes.taylorMap) throw new Error(`quantizeTaylorMap: taylorMap is not computed`)
        const [taylorMap, minValue, maxValue] = TensorUtils.quantize3d(this.computes.taylorMap) 
        this.computes.taylorMap.dispose()
        this.computes.taylorMap = taylorMap
        this.parameters.taylorMap.minValue = new THREE.Vector4().fromArray(minValue)
        this.parameters.taylorMap.maxValue = new THREE.Vector4().fromArray(maxValue) 
        // console.log('quantizedTaylorMap', this.parameters.taylorMap, this.computes.taylorMap.dataSync())
    }

    // helper functions

    generateTexture(key, format, type) 
    {
        if (!this.computes[key]) throw new Error(`${key} is not computed`)
        if (this.textures[key]) this.textures[key].dispose()
        this.textures[key] = new THREE.Data3DTexture(this.computes[key].dataSync(), ...this.parameters[key].dimensions.toArray())
        this.textures[key].format = format
        this.textures[key].type = type
        this.textures[key].minFilter = THREE.LinearFilter
        this.textures[key].magFilter = THREE.LinearFilter
        this.textures[key].generateMipmaps = false
        this.textures[key].needsUpdate = true

        return this.textures[key]
    }
    
    disposeMap(key) 
    {
        if (this.computes[key]) this.computes[key].dispose()
        if (this.textures[key]) this.textures[key].dispose()
        delete this.parameters[key]
    }
    
}