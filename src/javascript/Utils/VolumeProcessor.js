import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from './TensorUtils'
import { timeit } from './timeit'


/*
    Currently handles only spatial volume data without temporal information
*/
export default class VolumeProcessor 
{
    constructor(volume, renderer)
    {
        this.renderer = renderer
        this.volume = volume
        this.setObjects()
        this.setVolumeParameters()

        console.log(tf.memory())

        // this.computeIntensityMap()
        // this.computeGradientMap()
        // this.computeTaylorMap()
        // this.computeOccupancyMap(0, 4)
        // this.computeOccupancyMipmaps(0, 4)
        // this.computeOccupancyDistanceMap(0, 2, 255)
        // this.computeOccupancyBoundingBox(0)
        // this.computeExtremaMap(4)
        // this.computeExtremaDistanceMap(4, 40)
        // this.downscaleIntensityMap(2)
        // this.smoothIntensityMap(1)
        // this.quantizeIntensityMap(256)
        // this.quantizeGradientMap(256)
        // this.quantizeTaylorMap(256)
    }

    setObjects()
    {
        this.intensityMap = {}
        this.gradientMap = {}
        this.taylorMap = {}
        this.occupancyMap = {}
        this.occupancyDistanceMap = {}
        this.occupancyMipmaps = {}
        this.occupancyBoundingBox = {}
        this.extremaMap = {}
        this.extremaDistanceMap = {}
    }

    setVolumeParameters()
    {
        this.volume.params = 
        {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map(x => 1/x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map(x => 1/x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map(x => 1/x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            shape        : this.volume.dimensions.toReversed().concat(1),
        }
    }

    // compute functions

    async computeIntensityMap()
    {
        timeit('computeIntensityMap', () =>
        {
            if (this.intensityMap?.tensor) 
                this.intensityMap.tensor.dispose()

            this.intensityMap.tensor = tf.tensor4d(this.volume.data, this.volume.params.shape,'float32')

            this.intensityMap.params = {...this.volume.params}
            
            // console.log('intensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async computeGradientMap()
    {
        timeit('computeGradientMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeGradientMap: intensityMap is not computed`)

            if (this.gradientMap?.tensor) 
                this.gradientMap.tensor.dispose()
            
            this.gradientMap.tensor = TensorUtils.gradients3d(this.intensityMap.tensor, this.volume.params.spacing)
            
            this.gradientMap.params =  {...this.volume.params}
            this.gradientMap.params.shape = this.gradientMap.tensor.shape
            
            // console.log('gradientMap', this.gradientMap.params, this.gradientMap.tensor.dataSync())
        })
    }
 
    async computeTaylorMap()
    {
        timeit('computeTaylorMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeTaylorMap: intensityMap is not computed`)    

            if (!this.gradientMap?.tensor) 
                throw new Error(`computeTaylorMap: intensityMap is not computed`)   

            if (this.taylorMap?.tensor) 
                this.taylorMap.tensor.dispose()

            this.taylorMap.tensor = tf.concat([this.intensityMap.tensor, this.gradientMap.tensor], 3)

            this.taylorMap.params =  {...this.volume.params}
            this.taylorMap.params.shape = this.taylorMap.tensor.shape
            
            // console.log('taylorMap', this.taylorMap.params, this.taylorMap.tensor.dataSync())
        })       
    }

    async computeOccupancyMap(threshold = 0, division = 4)
    {
        timeit('computeOccupancyMap', () =>
        {
            if (this.occupancyMap?.tensor) 
                this.occupancyMap?.tensor.dispose()

            this.occupancyMap.tensor = TensorUtils.occupancyMap(this.intensityMap.tensor, threshold, division)

            this.occupancyMap.params = {}
            this.occupancyMap.params.threshold = threshold
            this.occupancyMap.params.division = division
            this.occupancyMap.params.dimensions = new THREE.Vector3().fromArray(this.occupancyMap.tensor.shape.slice(0, 3).toReversed())
            this.occupancyMap.params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(division)
            this.occupancyMap.params.size = new THREE.Vector3().copy(this.occupancyMap.params.dimensions).multiply(this.occupancyMap.params.spacing)
            this.occupancyMap.params.numBlocks = this.occupancyMap.params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            this.occupancyMap.params.shape = this.occupancyMap.tensor.shape
            
            // console.log('occupancyMap', this.occupancyMap.params, this.occupancyMap.tensor.dataSync())
        })
    }

    async computeOccupancyMipmaps(threshold = 0, division = 4)
    {
        timeit('computeOccupancyMipmaps', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeOccupancyMipmaps: intensityMap is not computed`)

            if (this.occupancyMipmaps?.tensor) 
                this.occupancyMipmaps.tensor.dispose()

            const occupancyMipmaps = TensorUtils.occupancyMipmaps(this.intensityMap.tensor, threshold, division)
            const compactOccupancyMipmaps = TensorUtils.compactMipmaps(occupancyMipmaps)

            this.occupancyMipmaps.tensor = compactOccupancyMipmaps
            this.occupancyMipmaps.params = {}
            this.occupancyMipmaps.params.threshold = threshold
            this.occupancyMipmaps.params.division = division
            this.occupancyMipmaps.params.levels = occupancyMipmaps.length
            this.occupancyMipmaps.params.dimensions = new THREE.Vector3().fromArray(compactOccupancyMipmaps.shape.slice(0, 3).toReversed())
            this.occupancyMipmaps.params.shape = compactOccupancyMipmaps.shape
            this.occupancyMipmaps.params.dimensions0 = new THREE.Vector3().fromArray(occupancyMipmaps[0].shape.slice(0, 3).toReversed())
            this.occupancyMipmaps.params.spacing0 = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(division)
            this.occupancyMipmaps.params.size0 = new THREE.Vector3().copy(this.occupancyMipmaps.params.dimensions0).multiply(this.occupancyMipmaps.params.spacing0)
            
            // console.log('occupancyMipmaps', this.occupancyMipmaps.params, this.occupancyMipmaps.tensor.dataSync())
        })        
    }

    async computeOccupancyDistanceMap(threshold = 0, division = 4, maxDistance = 255)
    {
        timeit('computeOccupancyDistanceMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeOccupancyDistanceMap: intensityMap is not computed`)

            if (this.occupancyDistanceMap?.tensor) 
                this.occupancyDistanceMap.tensor.dispose()

            this.occupancyDistanceMap.tensor = TensorUtils.occupancyDistanceMap(this.intensityMap.tensor, threshold, division, maxDistance)

            this.occupancyDistanceMap.params = {}
            this.occupancyDistanceMap.params.threshold = threshold
            this.occupancyDistanceMap.params.division = division
            this.occupancyDistanceMap.params.maxDistance = maxDistance
            this.occupancyDistanceMap.params.dimensions = new THREE.Vector3().fromArray(this.occupancyDistanceMap.tensor.shape.slice(0, 3).toReversed())
            this.occupancyDistanceMap.params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(this.occupancyDistanceMap.params.division)
            this.occupancyDistanceMap.params.size = new THREE.Vector3().copy(this.occupancyDistanceMap.params.dimensions).multiply(this.occupancyDistanceMap.params.spacing)
            this.occupancyDistanceMap.params.numBlocks = this.occupancyDistanceMap.params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            this.occupancyDistanceMap.params.shape = this.occupancyDistanceMap.tensor.shape

            console.log('occupancyDistanceMap', this.occupancyDistanceMap.params, this.occupancyDistanceMap.tensor.dataSync())
        })
    }

    async computeOccupancyBoundingBox(threshold = 0)
    {
        timeit('computeOccupancyBoundingBox', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeOccupancyBoundingBox: intensityMap is not computed`)

            const boundingBox = TensorUtils.occupancyBoundingBox(this.intensityMap.tensor, threshold)
  
            this.occupancyBoundingBox.params = {}
            this.occupancyBoundingBox.params.threshold = threshold
            this.occupancyBoundingBox.params.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
            this.occupancyBoundingBox.params.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
            this.occupancyBoundingBox.params.minPosition = new THREE.Vector3().fromArray(boundingBox.minCoords).multiply(this.volume.params.spacing)
            this.occupancyBoundingBox.params.maxPosition = new THREE.Vector3().fromArray(boundingBox.maxCoords).multiply(this.volume.params.spacing)

            // console.log('occupancyBoundingBox', this.occupancyBoundingBox.params)
        })
    }

    async computeExtremaMap(division = 4)
    {
        timeit('computeExtremaMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeExtremaMap: intensityMap is not computed`)

            if (this.extremaMap?.tensor) 
                this.extremaMap.tensor.dispose()

            this.extremaMap.tensor = TensorUtils.extremaMap(this.intensityMap.tensor, division)

            this.extremaMap.params = {}
            this.extremaMap.params.division = division
            this.extremaMap.params.dimensions = new THREE.Vector3().fromArray(this.extremaMap.tensor.shape.slice(0, 3).toReversed())
            this.extremaMap.params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(division)
            this.extremaMap.params.size = new THREE.Vector3().copy(this.extremaMap.params.dimensions).multiply(this.extremaMap.params.spacing)
            this.extremaMap.params.numBlocks = this.extremaMap.params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            this.extremaMap.params.shape = this.extremaMap.tensor.shape
            
            // console.log('extremaMap', this.extremaMap.params, this.extremaMap.tensor.dataSync())
        })
    }

    async computeExtremaDistanceMap(division = 4, maxDistance = 255)
    {
        timeit('computeExtremaDistanceMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`computeExtremaDistanceMap: intensityMap is not computed`)

            if (this.extremaDistanceMap?.tensor) 
                this.extremaDistanceMap.tensor.dispose()

            this.extremaDistanceMap.tensor = TensorUtils.extremaDistanceMap(this.intensityMap.tensor, division, maxDistance)
            this.extremaDistanceMap.params = {}
            this.extremaDistanceMap.params.division = division
            this.extremaDistanceMap.params.maxDistance = maxDistance
            this.extremaDistanceMap.params.dimensions = new THREE.Vector3().fromArray(this.extremaDistanceMap.tensor.shape.slice(0, 3).toReversed())
            this.extremaDistanceMap.params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(division)
            this.extremaDistanceMap.params.size = new THREE.Vector3().copy(this.extremaDistanceMap.params.dimensions).multiply(this.extremaDistanceMap.params.spacing)
            this.extremaDistanceMap.params.numBlocks = this.extremaDistanceMap.params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            this.extremaDistanceMap.params.shape = this.extremaDistanceMap.tensor.shape

            // console.log('extremaDistanceMap', this.extremaDistanceMap.params, this.extremaDistanceMap.tensor.dataSync())
        })
    }

    // alter functions

    async normalizeIntensityMap()
    {
        timeit('normalizeIntensityMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`normalizeIntensityMap: intensityMap is not computed`)

            const [normalizedIntensityMap, minValue, maxValue] = TensorUtils.normalize3d(this.intensityMap.tensor) 

            this.intensityMap.tensor.dispose()
            this.intensityMap.tensor = normalizedIntensityMap
            this.intensityMap.params.minValue = minValue[0]
            this.intensityMap.params.maxValue = maxValue[0]  

            // console.log('normalizedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async downscaleIntensityMap(scale = 2)
    {
        timeit('downscaleIntensityMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`downscaleIntensityMap: intensityMap is not computed`)

            const intensityMap = TensorUtils.downscale3d(this.intensityMap.tensor, scale)

            this.intensityMap.tensor.dispose()
            this.intensityMap.tensor = intensityMap
            this.intensityMap.params.downScale = scale
            this.intensityMap.params.dimensions = new THREE.Vector3().fromArray(this.intensityMap.tensor.shape.slice(0, 3).toReversed())
            this.intensityMap.params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(scale)
            this.intensityMap.params.size = new THREE.Vector3().copy(this.intensityMap.params.dimensions).multiply(this.intensityMap.params.spacing)
            this.intensityMap.params.numBlocks = this.intensityMap.params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
            this.intensityMap.params.shape = this.intensityMap.tensor.shape

            // console.log('downscaledIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async smoothIntensityMap(radius = 1)
    {
        timeit('downscaleIntensityMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`smoothIntensityMap: intensityMap is not computed`)

            const downscaledIntensityMap = TensorUtils.smooth3d(this.intensityMap.tensor, radius)

            this.intensityMap.tensor.dispose()
            this.intensityMap.tensor = downscaledIntensityMap
            this.intensityMap.params.smoothingRadius = radius
            
            // console.log('smoothedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async quantizeIntensityMap()
    {
        timeit('quantizeIntensityMap', () =>
        {
            if (!this.intensityMap?.tensor) 
                throw new Error(`quantizeIntensityMap: intensityMap is not computed`)

            const [quantizedIntensityMap, minValue, maxValue] = TensorUtils.quantize3d(this.intensityMap.tensor) 

            this.intensityMap.tensor.dispose()
            this.intensityMap.tensor = quantizedIntensityMap
            this.intensityMap.params.minValue = minValue
            this.intensityMap.params.maxValue = maxValue  
            
            // console.log('quantizedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async quantizeGradientMap()
    {
        timeit('quantizeGradientMap', () =>
        {
            if (!this.gradientMap?.tensor) 
                throw new Error(`quantizeGradientMap: gradientMap is not computed`)

            const [quantizedGradientMap, minValue, maxValue] = TensorUtils.quantize3d(this.gradientMap.tensor) 

            this.gradientMap.tensor.dispose()
            this.gradientMap.tensor = quantizedGradientMap
            this.gradientMap.params.minValue = new THREE.Vector3().fromArray(minValue)
            this.gradientMap.params.maxValue = new THREE.Vector3().fromArray(maxValue) 
            
            // console.log('quantizedGradientMap', this.gradientMap.params, this.gradientMap.tensor.dataSync())
        })
    }

    async quantizeTaylorMap()
    {
        timeit('quantizeTaylorMap', () =>
        {
            if (!this.taylorMap?.tensor) 
                throw new Error(`quantizeTaylorMap: taylorMap is not computed`)

            const [quantizedTaylorMap, minValue, maxValue] = TensorUtils.quantize3d(this.taylorMap.tensor) 

            this.taylorMap.tensor.dispose()
            this.taylorMap.tensor = quantizedTaylorMap
            this.taylorMap.params.minValue = new THREE.Vector4().fromArray(minValue)
            this.taylorMap.params.maxValue = new THREE.Vector4().fromArray(maxValue) 
            
            // console.log('quantizedTaylorMap', this.taylorMap.params, this.taylorMap.tensor.dataSync())
        })
    }

    // helper functions

    getTexture(key, format, type) 
    {
        timeit(`generateTexture(${key})`, () =>
        {
            if (!this[key]?.tensor) 
                throw new Error(`${key} is not computed`)

            if (this[key]?.texture) 
                this[key].texture.dispose()

            let array
            switch (type) 
            {
                case THREE.FloatType:
                    array = new Float32Array(this[key].tensor.dataSync())
                    break
                case THREE.UnsignedByteType:
                    array = new Uint8Array(this[key].tensor.dataSync())
                    break
                case THREE.UnsignedShortType:
                    array = new Uint16Array(this[key].tensor.dataSync())
                    break
                case THREE.ByteType:
                    array = new Int8Array(this[key].tensor.dataSync())
                    break
                case THREE.ShortType:
                    array = new Int16Array(this[key].tensor.dataSync())
                    break
                case THREE.IntType:
                    array = new Int32Array(this[key].tensor.dataSync())
                    break
                default:
                    throw new Error(`Unsupported type: ${type}`)
            }

            let dimensions = this[key].params.dimensions.toArray()
            this[key].texture = new THREE.Data3DTexture(array, ...dimensions)
            this[key].texture.format = format
            this[key].texture.type = type
            this[key].texture.minFilter = THREE.LinearFilter
            this[key].texture.magFilter = THREE.LinearFilter
            this[key].texture.generateMipmaps = false
            this[key].texture.needsUpdate = true
        })

        return this[key].texture
    }
    
    destroy() 
    {
        Object.keys(this).forEach(key => 
        {
            // console.log(this[key])

            if (this[key]?.tensor) 
                this[key].tensor.dispose()

            if (this[key]?.texture) 
                this[key].texture.dispose()

            if (this[key]?.params) 
                delete this[key].params
        })

        this.volume = null;
        this.renderer = null;
    
        console.log("VolumeProcessor destroyed.");
    }
    
}