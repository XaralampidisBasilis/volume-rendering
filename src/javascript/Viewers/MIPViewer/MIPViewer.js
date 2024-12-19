import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Experience from '../../Experience'
import EventEmitter from '../../Utils/EventEmitter'
import VolumeProcessor from '../../Utils/VolumeProcessor'
import MIPMaterial from './MIPMaterial'
import MIPGui from './MIPGui'

export default class MIPViewer extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.camera = this.experience.camera
        this.sizes = this.experience.sizes
        this.debug = this.experience.debug
        this.material = MIPMaterial()
        this.gui = new MIPGui(this)

        this.processor = new VolumeProcessor(this.resources.items.volumeNifti)
        this.precompute().then(() => 
        {
            this.setParameters()
            this.setTextures()
            this.setGeometry()
            this.setMaterial()
            this.setMesh()
            this.logMemory('precompute')
            this.trigger('ready')
        })
    }
    
    async precompute()
    {
        const uExtremap = this.material.uniforms.u_extremap.value

        await this.processor.computeIntensityMap()
        await this.processor.normalizeIntensityMap()
        await this.processor.computeGradientMap()
        await this.processor.computeTaylorMap().then(() => this.processor.gradientMap.tensor.dispose())
        await this.processor.quantizeTaylorMap()
        await this.processor.quantizeIntensityMap()
        await this.processor.computeExtremaDualMap(uExtremap.sub_division)
    }

    async updateExtremaMap()
    {
        const uExtremap = this.material.uniforms.u_extremap.value
        const uTextures = this.material.uniforms.u_textures.value

        await this.processor.computeExtremaDualMap(uExtremap.sub_division)
        
        const extremaParams =  this.processor.extremaDualMap.params
        uExtremap.sub_division = extremaParams.sub_division
        uExtremap.dimensions.copy(extremaParams.dimensions)
        uExtremap.spacing.copy(extremaParams.spacing)
        uExtremap.size.copy(extremaParams.size)
        uExtremap.inv_dimensions.copy(extremaParams.invDimensions)
        uExtremap.inv_spacing.copy(extremaParams.invSpacing)
        uExtremap.inv_size.copy(extremaParams.invSize)

        uTextures.extrema_map.dispose()
        uTextures.extrema_map = this.processor.getTexture('extremaDualMap', THREE.RGFormat, THREE.UnsignedByteType)
        uTextures.extrema_map.needsUpdate = true
        this.processor.extremaDualMap.tensor.dispose()

        this.logMemory('updateExtremaMap')
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.volume = this.processor.volume.params
    }

    setTextures()
    {
        this.textures = {}

        // taylor_map
        this.textures.taylor_map = this.processor.getTexture('taylorMap', THREE.RGBAFormat, THREE.UnsignedByteType)
        this.processor.taylorMap.tensor.dispose()

        // extrema_map
        this.textures.extrema_map = this.processor.getTexture('extremaDualMap', THREE.RGFormat, THREE.UnsignedByteType)
        this.processor.extremaDualMap.tensor.dispose()

        // color_maps
        this.textures.color_maps = this.resources.items.colormaps                      
        this.textures.color_maps.colorSpace = THREE.SRGBColorSpace
        this.textures.color_maps.minFilter = THREE.LinearFilter
        this.textures.color_maps.magFilter = THREE.LinearFilter         
        this.textures.color_maps.generateMipmaps = false
        this.textures.color_maps.needsUpdate = true 
    }
  
    setGeometry()
    {
        const size = this.parameters.volume.size
        const center = this.parameters.volume.size.clone().divideScalar(2)
        this.geometry = new THREE.BoxGeometry(...size)
        
        // In order to align model vertex coordinates with texture coordinates
        // we translate all with the center, so now they start at zero
        this.geometry.translate(...center) 
    }

    setMaterial()
    {        
        // parameters
        const volumeParams = this.processor.volume.params
        const taylormapParams = this.processor.taylorMap.params
        const extremaParams =  this.processor.extremaDualMap.params

        // uniforms
        const uVolume = this.material.uniforms.u_volume.value
        const uExtremap = this.material.uniforms.u_extremap.value
        const uTextures = this.material.uniforms.u_textures.value

        // volume
        uVolume.dimensions.copy(volumeParams.dimensions)
        uVolume.spacing.copy(volumeParams.spacing)
        uVolume.size.copy(volumeParams.size)
        uVolume.size_length = volumeParams.sizeLength
        uVolume.spacing_length = volumeParams.spacingLength
        uVolume.inv_dimensions.copy(volumeParams.invDimensions)
        uVolume.inv_spacing.copy(volumeParams.invSpacing)
        uVolume.inv_size.copy(volumeParams.invSize)
        uVolume.min_intensity = taylormapParams.minValue.x
        uVolume.max_intensity = taylormapParams.maxValue.x
        uVolume.min_gradient.fromArray(taylormapParams.minValue.toArray().slice(1))
        uVolume.max_gradient.fromArray(taylormapParams.maxValue.toArray().slice(1))
        uVolume.max_gradient_length = Math.max(uVolume.max_gradient.length(), uVolume.min_gradient.length())

        // extrema_map
        uExtremap.sub_division = extremaParams.sub_division
        uExtremap.dimensions.copy(extremaParams.dimensions)
        uExtremap.spacing.copy(extremaParams.spacing)
        uExtremap.size.copy(extremaParams.size)
        uExtremap.inv_dimensions.copy(extremaParams.invDimensions)
        uExtremap.inv_spacing.copy(extremaParams.invSpacing)
        uExtremap.inv_size.copy(extremaParams.invSize)

        // textures
        uTextures.taylor_map = this.textures.taylor_map
        uTextures.extrema_map = this.textures.extrema_map
        uTextures.color_maps = this.textures.color_maps   
    }

    setMesh()
    {   
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(-0.5)
        this.scene.add(this.mesh)
    }

    destroy() 
    {
    
        Object.keys(this.textures).forEach(key => 
        {
            if (this.textures[key]) 
                this.textures[key].dispose()
        })
    
        if (this.mesh) 
        {
            this.scene.remove(this.mesh)
            this.mesh.geometry.dispose()
            this.mesh.material.dispose()
        }
    
        // if (this.gui) 
        //     this.gui.destroy()

        if (this.processor)
            this.processor.destroy()

        // Clean up references
        this.scene = null
        this.resources = null
        this.renderer = null
        this.camera = null
        this.sizes = null
        this.debug = null
        this.mesh = null
        this.gui = null

        console.log("MIPViewer destroyed")
    }

    logMemory(fun)
    {
        console.log(`${fun}: Tensors = ${tf.memory().numTensors}, Textures = ${this.renderer.instance.info.memory.textures}`)
    }
    
}