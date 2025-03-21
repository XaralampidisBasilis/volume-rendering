import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import EventEmitter from '../../Utils/EventEmitter'
import MPRViewer from './MPRViewer'

export default class Textures extends EventEmitter
{
    constructor()
    {
        super()

        // Setup
        this.viewer = new MPRViewer()
        this.resources = this.viewer.resources
        this.computes = this.viewer.computes

        // Wait for computes
        this.computes.on('ready', () =>
        {
            this.setTextures()
        })
    }

    async setTextures()
    {
        console.time('Textures')

        this.setColorMaps()
        this.setIntensityMap()
        this.setBinaryMap()
        this.setDistanceMap()

        this.trigger('ready')
        console.timeEnd('Textures')
    }

    setColorMaps()
    {
        this.colorMaps = this.resources.items.colorMaps

        this.colorMaps.colorSpace = THREE.SRGBColorSpace
        this.colorMaps.minFilter = THREE.LinearFilter
        this.colorMaps.magFilter = THREE.LinearFilter
        this.colorMaps.generateMipmaps = false
        this.colorMaps.needsUpdate = true
    }

    setIntensityMap()
    {
        const source = this.computes.intensityMap
        const data = source.tensor.dataSync()
        const dims = source.parameters.dimensions

        this.intensityMap = new THREE.Data3DTexture(data, ...dims)
        this.intensityMap.format = THREE.RedFormat
        this.intensityMap.type = THREE.FloatType
        this.intensityMap.minFilter = THREE.LinearFilter
        this.intensityMap.magFilter = THREE.LinearFilter
        this.intensityMap.computeMipmaps = false
        this.intensityMap.needsUpdate = true

        tf.dispose(source.tensor)
    }

    setBinaryMap()
    {
        const source = this.computes.binaryMap
        const data = source.tensor.dataSync()
        const dims = source.parameters.dimensions

        this.binaryMap = new THREE.Data3DTexture(data, ...dims)
        this.binaryMap.format = THREE.RedFormat
        this.binaryMap.type = THREE.UnsignedByteType
        this.binaryMap.minFilter = THREE.LinearFilter
        this.binaryMap.magFilter = THREE.LinearFilter
        this.binaryMap.computeMipmaps = false
        this.binaryMap.needsUpdate = true

        tf.dispose(source.tensor)
    }

    setDistanceMap()
    {
        const source = this.computes.distanceMap
        const data = new Int8Array(source.tensor.dataSync())
        const dims = source.parameters.dimensions

        this.distanceMap = new THREE.Data3DTexture(data, ...dims)
        this.distanceMap.format = THREE.RedIntegerFormat
        this.distanceMap.type = THREE.ByteType
        this.distanceMap.minFilter = THREE.NearestFilter
        this.distanceMap.magFilter = THREE.NearestFilter
        this.distanceMap.computeMipmaps = false
        this.distanceMap.needsUpdate = true

        tf.dispose(source.tensor)
    }

    destroy() 
    {
        if (this.colorMaps)
        {
            this.colorMaps.dispose()
            this.colorMaps = null
        }

        if (this.intensityMap)
        {
            this.intensityMap.dispose()
            this.intensityMap = null
        }

        if (this.binaryMap)
        {
            this.binaryMap.dispose()
            this.binaryMap = null
        }

        if (this.distanceMap)
        {
            this.distanceMap.dispose()
            this.distanceMap = null
        }

        this.viewer = null
        this.resources = null
        this.computes = null

        console.log('Textures destroyed.')
    }

}