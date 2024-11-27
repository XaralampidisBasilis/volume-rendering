import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from '../TensorUtils'
import EventEmitter from '../EventEmitter'
import timeit from '../timeit'

export default class VolumeProcessor extends EventEmitter
{
    constructor(volume, renderer)
    {
        super()

        this.renderer = renderer
        this.volume = volume
        this.setParameters()
        this.setTensors()
        this.setTextures()

        // timeit(() => this.computeVolumeCompander(), 'computeVolumeCompander')
        // timeit(() => this.computeGradients(), 'computeGradients')
        // timeit(() => this.computeOccupancyMap(0, 10), 'computeOccupancyMap')
        // timeit(() => this.computeOccupancyAtlas(), 'computeOccupancyAtlas')
        // timeit(() => this.computeOccupancyDistanceMap(0, 10, 255), 'computeOccupancyDistanceMap')
        // timeit(() => this.computeExtremaMap(10), 'computeExtremaMap')
        timeit(() => this.computeExtremaDistanceMap(2, 40), 'computeExtremaDistanceMap')

        console.log(this.parameters.extremaDistanceMap)
        console.log(this.tensors.gradients.dataSync())
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = 
        {
            size         : new THREE.Vector3().fromArray(this.volume.size),
            dimensions   : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing      : new THREE.Vector3().fromArray(this.volume.spacing),
            invSize      : new THREE.Vector3().fromArray(this.volume.size.map((x) => 1 / x)),
            invDimensions: new THREE.Vector3().fromArray(this.volume.dimensions.map((x) => 1 / x)),
            invSpacing   : new THREE.Vector3().fromArray(this.volume.spacing.map((x) => 1 / x)),
            numVoxels    : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
        }
    }

    setTensors()
    {
        this.tensors = {}
        const volumeShape = this.volume.dimensions.toReversed().concat(1).concat(1)
        this.tensors.volume = tf.tensor5d(this.volume.data, volumeShape,'float32')
    }

    setTextures()
    {
        this.textures = {}
        this.textures.volume = new THREE.Data3DTexture(this.tensors.volume.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.volume.format = THREE.RedFormat
        this.textures.volume.type = THREE.FloatType     
        this.textures.volume.minFilter = THREE.LinearFilter
        this.textures.volume.magFilter = THREE.LinearFilter
        this.textures.volume.generateMipmaps = false
        this.textures.volume.needsUpdate = true   
    }

    computeResizeLinear()
    {

    }

    computeSmoothing(radius)
    {
        // dispose
        if (this.tensors.smoothed) this.tensors.smoothed.dispose()
        if (this.textures.smoothed) this.textures.smoothed.dispose()

        // tensors
        this.tensors.smoothed = TensorUtils.smoothing3d(this.tensors.volume, radius)

        // textures
        this.textures.smoothed = new THREE.Data3DTexture(this.tensors.smoothed.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.smoothed.format = THREE.RedFormat
        this.textures.smoothed.type = THREE.FloatType     
        this.textures.smoothed.minFilter = THREE.LinearFilter
        this.textures.smoothed.magFilter = THREE.LinearFilter
        this.textures.smoothed.generateMipmaps = false
        this.textures.smoothed.needsUpdate = true   
    }

    computeGradients()
    {
        // tensors
        if (this.tensors.gradients) this.tensors.gradients.dispose()
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)

        // textures
        if (this.textures.gradients) this.textures.gradients.dispose()
        this.textures.gradients = new THREE.Data3DTexture(this.tensors.gradients.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.gradients.format = THREE.RGBFormat
        this.textures.gradients.type = THREE.FloatType     
        this.textures.gradients.minFilter = THREE.LinearFilter
        this.textures.gradients.magFilter = THREE.LinearFilter
        this.textures.gradients.generateMipmaps = false
        this.textures.gradients.needsUpdate = true   

        // dispose
        this.tensors.gradients.dispose()
    }

    computeTaylorMap()
    {
        // tensors
        if (this.tensors.gradients) this.tensors.gradients.dispose()
        if (this.tensors.taylorMap) this.tensors.taylorMap.dispose()
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)
        this.tensors.taylorMap = tf.concat([this.tensors.volume, this.tensors.gradients], 3)
        this.tensors.gradients.dispose()

        // textures
        if (this.textures.taylorMap) this.textures.taylorMap.dispose()
        this.textures.taylorMap = new THREE.Data3DTexture(this.tensors.taylorMap.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.taylorMap.format = THREE.RGBAFormat
        this.textures.taylorMap.type = THREE.FloatType     
        this.textures.taylorMap.minFilter = THREE.LinearFilter
        this.textures.taylorMap.magFilter = THREE.LinearFilter
        this.textures.taylorMap.generateMipmaps = false
        this.textures.taylorMap.needsUpdate = true   

        // dispose
        this.tensors.taylorMap.dispose()
    }

    computeVolumeQuantization()
    {
        // parameters
        this.parameters.volumeQuantized = this.parameters.volume

        // tensors
        if (this.tensors.volumeQuantized) this.tensors.volumeQuantized.dispose()
        [this.tensors.volumeQuantized, this.parameters.volumeQuantized.minValue, this.parameters.volumeQuantized.maxValue] = TensorUtils.quantize(this.tensors.volume)

        // textures
        if (this.textures.volumeQuantized) this.textures.volumeQuantized.dispose()
        this.textures.volumeQuantized = new THREE.Data3DTexture(this.tensors.volumeQuantized.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.volumeQuantized.format = THREE.RGBFormat
        this.textures.volumeQuantized.type = THREE.FloatType     
        this.textures.volumeQuantized.minFilter = THREE.LinearFilter
        this.textures.volumeQuantized.magFilter = THREE.LinearFilter
        this.textures.volumeQuantized.generateMipmaps = false
        this.textures.volumeQuantized.needsUpdate = true   

        // dispose
        this.tensors.volumeQuantized.dispose()

    }
    
    computeGradientsQuantization()
    {
        // tensors
        this.tensors.gradientsQuantized = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)

        // textures
        if (this.textures.gradientsQuantized) this.textures.gradientsQuantized.dispose()
        this.textures.gradientsQuantized = new THREE.Data3DTexture(this.tensors.gradientsQuantized.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.gradientsQuantized.format = THREE.RGBFormat
        this.textures.gradientsQuantized.type = THREE.FloatType     
        this.textures.gradientsQuantized.minFilter = THREE.LinearFilter
        this.textures.gradientsQuantized.magFilter = THREE.LinearFilter
        this.textures.gradientsQuantized.generateMipmaps = false
        this.textures.gradientsQuantized.needsUpdate = true   

        // dispose
        this.tensors.gradientsQuantized.dispose()
    }

    computeTaylorMapQuantization()
    {
        // tensors
        if (this.tensors.gradients) this.tensors.gradients.dispose()
        if (this.tensors.taylorMap) this.tensors.taylorMap.dispose()
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)
        this.tensors.taylorMap = tf.concat([this.tensors.volume, this.tensors.gradients], 3)
        this.tensors.gradients.dispose()

        // textures
        if (this.textures.taylorMap) this.textures.taylorMap.dispose()
        this.textures.taylorMap = new THREE.Data3DTexture(this.tensors.taylorMap.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.taylorMap.format = THREE.RGBAFormat
        this.textures.taylorMap.type = THREE.FloatType     
        this.textures.taylorMap.minFilter = THREE.LinearFilter
        this.textures.taylorMap.magFilter = THREE.LinearFilter
        this.textures.taylorMap.generateMipmaps = false
        this.textures.taylorMap.needsUpdate = true   

        // dispose
        this.tensors.taylorMap.dispose()
    }

    computeVolumeCompanding()
    {
        // tensors
        if (this.tensors.gradients) this.tensors.gradients.dispose()
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)

        // textures
        if (this.textures.gradients) this.textures.gradients.dispose()
        this.textures.gradients = new THREE.Data3DTexture(this.tensors.gradients.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.gradients.format = THREE.RGBFormat
        this.textures.gradients.type = THREE.FloatType     
        this.textures.gradients.minFilter = THREE.LinearFilter
        this.textures.gradients.magFilter = THREE.LinearFilter
        this.textures.gradients.generateMipmaps = false
        this.textures.gradients.needsUpdate = true   
    }
    
    computeGradientsCompanding()
    {
        // tensors
        this.tensors.gradientsQuantized = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)

        // textures
        if (this.textures.gradientsQuantized) this.textures.gradientsQuantized.dispose()
        this.textures.gradientsQuantized = new THREE.Data3DTexture(this.tensors.gradientsQuantized.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.gradientsQuantized.format = THREE.RGBFormat
        this.textures.gradientsQuantized.type = THREE.FloatType     
        this.textures.gradientsQuantized.minFilter = THREE.LinearFilter
        this.textures.gradientsQuantized.magFilter = THREE.LinearFilter
        this.textures.gradientsQuantized.generateMipmaps = false
        this.textures.gradientsQuantized.needsUpdate = true   

        // dispose
        this.tensors.gradientsQuantized.dispose()
    }

    computeTaylorMapCompanding()
    {
        // tensors
        if (this.tensors.gradients) this.tensors.gradients.dispose()
        if (this.tensors.taylorMap) this.tensors.taylorMap.dispose()
        this.tensors.gradients = TensorUtils.gradients3d(this.tensors.volume, this.parameters.volume.spacing)
        this.tensors.taylorMap = tf.concat([this.tensors.volume, this.tensors.gradients], 3)
        this.tensors.gradients.dispose()

        // textures
        if (this.textures.taylorMap) this.textures.taylorMap.dispose()
        this.textures.taylorMap = new THREE.Data3DTexture(this.tensors.taylorMap.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.taylorMap.format = THREE.RGBAFormat
        this.textures.taylorMap.type = THREE.FloatType     
        this.textures.taylorMap.minFilter = THREE.LinearFilter
        this.textures.taylorMap.magFilter = THREE.LinearFilter
        this.textures.taylorMap.generateMipmaps = false
        this.textures.taylorMap.needsUpdate = true   

        // dispose
        this.tensors.taylorMap.dispose()
    }

    computeOccupancyMap(threshold, division)
    {
        // tensors
        this.tensors.occupancyMap = TensorUtils.occupancyMap(this.tensors.volume, threshold, division)

        // parameters
        this.parameters.occupancyMap = {}
        this.parameters.occupancyMap.threshold = threshold
        this.parameters.occupancyMap.division = division
        this.parameters.occupancyMap.dimensions = new THREE.Vector3().fromArray(this.tensors.occupancyMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.occupancyMap.division)
        this.parameters.occupancyMap.size = new THREE.Vector3().copy(this.parameters.occupancyMap.dimensions).multiply(this.parameters.occupancyMap.spacing)
        this.parameters.occupancyMap.numBlocks = this.parameters.occupancyMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        
        // textures
        if (this.textures.occupancyMap) this.textures.occupancyMap.dispose()
        this.textures.occupancyMap = new THREE.Data3DTexture(this.tensors.occupancyMap.data(), ...this.parameters.occupancyMap.dimensions.toArray())
        this.textures.occupancyMap.format = THREE.RedFormat
        this.textures.occupancyMap.type = THREE.UnsignedByteType     
        this.textures.occupancyMap.minFilter = THREE.LinearFilter
        this.textures.occupancyMap.magFilter = THREE.LinearFilter
        this.textures.occupancyMap.generateMipmaps = false
        this.textures.occupancyMap.needsUpdate = true   

        // dispose
        this.tensors.occupancyMap.dispose()
    }

    computeOccupancyAtlas(threshold, division)
    {
        this.tensors.occupancyAtlas = TensorUtils.occupancyAtlas(this.tensors.volume, threshold, division)
        this.textures.occupancyAtlas = new THREE.Data3DTexture(this.tensors.occupancyAtlas.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.occupancyAtlas.format = THREE.RedFormat
        this.textures.occupancyAtlas.type = THREE.UnsignedByteType     
        this.textures.occupancyAtlas.minFilter = THREE.LinearFilter
        this.textures.occupancyAtlas.magFilter = THREE.LinearFilter
        this.textures.occupancyAtlas.generateMipmaps = false
        this.textures.occupancyAtlas.needsUpdate = true   
    }

    computeOccupancyDistanceMap(threshold, division, maxDistance)
    {
        // parameters
        this.parameters.occupancyDistanceMap = {}
        this.parameters.occupancyDistanceMap.threshold = threshold
        this.parameters.occupancyDistanceMap.division = division
        this.parameters.occupancyDistanceMap.maxDistance = maxDistance
        this.parameters.occupancyDistanceMap.dimensions = new THREE.Vector3().fromArray(this.tensors.occupancyDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.occupancyDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.occupancyDistanceMap.division)
        this.parameters.occupancyDistanceMap.size = new THREE.Vector3().copy(this.parameters.occupancyDistanceMap.dimensions).multiply(this.parameters.occupancyDistanceMap.spacing)
        this.parameters.occupancyDistanceMap.numBlocks = this.parameters.occupancyDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        
        // textures
        if (this.textures.occupancyDistanceMap) this.textures.occupancyDistanceMap.dispose()
        this.textures.occupancyDistanceMap = new THREE.Data3DTexture(this.tensors.occupancyDistanceMap.data(), ...this.parameters.occupancyDistanceMap.dimensions.toArray())
        this.textures.occupancyDistanceMap.format = THREE.RedFormat
        this.textures.occupancyDistanceMap.type = THREE.UnsignedByteType     
        this.textures.occupancyDistanceMap.minFilter = THREE.LinearFilter
        this.textures.occupancyDistanceMap.magFilter = THREE.LinearFilter
        this.textures.occupancyDistanceMap.generateMipmaps = false
        this.textures.occupancyDistanceMap.needsUpdate = true   
        
        // dispose
        this.tensors.occupancyDistanceMap.dispose()
    }

    computeExtremaMap(division)
    {
        // tensors
        this.tensors.extremaMap = TensorUtils.extremaMap(this.tensors.volume, division)
        
        // parameters
        this.parameters.extremaMap = {}
        this.parameters.extremaMap.division = division
        this.parameters.extremaMap.dimensions = new THREE.Vector3().fromArray(this.tensors.extremaMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.extremaMap.division)
        this.parameters.extremaMap.size = new THREE.Vector3().copy(this.parameters.extremaMap.dimensions).multiply(this.parameters.extremaMap.spacing)
        this.parameters.extremaMap.numBlocks = this.parameters.extremaMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
        
        // textures
        if (this.textures.extremaMap) this.textures.extremaMap.dispose()
        this.textures.extremaMap = new THREE.Data3DTexture(this.tensors.extremaMap.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.extremaMap.format = THREE.RGFormat
        this.textures.extremaMap.type = THREE.FloatType     
        this.textures.extremaMap.minFilter = THREE.LinearFilter
        this.textures.extremaMap.magFilter = THREE.LinearFilter
        this.textures.extremaMap.generateMipmaps = false
        this.textures.extremaMap.needsUpdate = true   

        // dispose
        this.tensors.extremaMap.dispose()
    }

    computeExtremaDistanceMap(division, maxDistance)
    {
        // tensors
        this.tensors.extremaDistanceMap = TensorUtils.extremaDistanceMap(this.tensors.volume, division, maxDistance)

        // parameters
        this.parameters.extremaDistanceMap = {}
        this.parameters.extremaDistanceMap.division = division
        this.parameters.extremaDistanceMap.maxDistance = maxDistance
        this.parameters.extremaDistanceMap.dimensions = new THREE.Vector3().fromArray(this.tensors.extremaDistanceMap.shape.slice(0, 3).toReversed())
        this.parameters.extremaDistanceMap.spacing = new THREE.Vector3().copy(this.parameters.volume.spacing).multiplyScalar(this.parameters.extremaDistanceMap.division)
        this.parameters.extremaDistanceMap.size = new THREE.Vector3().copy(this.parameters.extremaDistanceMap.dimensions).multiply(this.parameters.extremaDistanceMap.spacing)
        this.parameters.extremaDistanceMap.numBlocks = this.parameters.extremaDistanceMap.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)

        // textures
        if (this.textures.extremaDistanceMap) this.textures.extremaDistanceMap.dispose()
        this.textures.extremaDistanceMap = new THREE.Data3DTexture(this.tensors.extremaDistanceMap.data(), ...this.parameters.volume.dimensions.toArray())
        this.textures.extremaDistanceMap.format = THREE.RedFormat
        this.textures.extremaDistanceMap.type = THREE.FloatType     
        this.textures.extremaDistanceMap.minFilter = THREE.LinearFilter
        this.textures.extremaDistanceMap.magFilter = THREE.LinearFilter
        this.textures.extremaDistanceMap.generateMipmaps = false
        this.textures.extremaDistanceMap.needsUpdate = true   

        // dispose
        this.tensors.extremaDistanceMap.dispose()
    }
}