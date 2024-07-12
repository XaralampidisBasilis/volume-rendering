import * as THREE from 'three'
import { TransformControls } from 'three/examples/jsm/controls/TransformControls.js'
import Experience from '../Experience.js'
import ISOMaterial from '../Materials/ISOMaterial.js'
import ISOGui from '../Gui/ISOGui.js'
import ISOHelpers from '../Helpers/ISOHelpers.js'
import ISOOccupancy from '../Computes/GPGPU/ISOOccupancy.js'

export default class ISOViewer
{
    constructor()
    {
        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.renderer = this.experience.renderer
        this.debug = this.experience.debug

        // Resource
        this.resource = {}        
        this.resource.volume = this.resources.items.volumeNifti
        this.resource.mask = this.resources.items.maskNifti  

        this.setParameters()
        this.setNoisemaps()
        this.setColormaps()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()

        if (this.debug.active) 
        {
            // this.helpers = new ISOHelpers(this)
            this.gui = new ISOGui(this)
        }

        // setup occupancy
        this.occupancy = new ISOOccupancy(this)
        this.occupancy.on('ready', () => 
        {
            // this.helpers.update()
        })
    }

    setParameters()
    {
        this.parameters = {}
        
        this.parameters.volume = {
            size: new THREE.Vector3().fromArray(this.resource.volume.size),
            dimensions: new THREE.Vector3().fromArray(this.resource.volume.dimensions),
            spacing: new THREE.Vector3().fromArray(this.resource.volume.spacing),
        }

        this.parameters.mask = {
            size: new THREE.Vector3().fromArray(this.resource.mask.size),
            dimensions: new THREE.Vector3().fromArray(this.resource.mask.dimensions),
            spacing: new THREE.Vector3().fromArray(this.resource.mask.spacing),
        }

        this.parameters.geometry = {
            size: new THREE.Vector3().copy(this.parameters.volume.size).add(this.parameters.volume.spacing),
            translation: new THREE.Vector3().copy(this.parameters.volume.size).sub(this.parameters.volume.spacing).divideScalar(2),
        }
    }

    setNoisemaps()
    {
        this.noisemaps = {}        
        this.noisemaps.white256 = this.resources.items.white256Noisemap

        this.noisemaps.white256.repeat.set(4, 4)
        this.noisemaps.white256.format = THREE.RedFormat
        this.noisemaps.white256.type = THREE.UnsignedByteType
        this.noisemaps.white256.wrapS = THREE.RepeatWrapping
        this.noisemaps.white256.wrapT = THREE.RepeatWrapping
        this.noisemaps.white256.minFilter = THREE.NearestFilter
        this.noisemaps.white256.magFilter = THREE.NearestFilter
        this.noisemaps.white256.needsUpdate = true            
    }

    setColormaps()
    {        
        this.colormaps = this.resources.items.colormaps                      
        this.colormaps.colorSpace = THREE.SRGBColorSpace
        this.colormaps.minFilter = THREE.LinearFilter
        this.colormaps.magFilter = THREE.LinearFilter         
        this.colormaps.needsUpdate = true  
    }

    setTextures()
    {
        this.textures = {}

        // Volume
        this.textures.volume = new THREE.Data3DTexture( 
            this.resource.volume.getDataUint8(), 
            this.resource.volume.xLength, 
            this.resource.volume.yLength,
            this.resource.volume.zLength 
        )          

        // Mask
        this.textures.mask = new THREE.Data3DTexture( 
            this.resource.mask.getDataUint8(), 
            this.resource.mask.xLength, 
            this.resource.mask.yLength,
            this.resource.mask.zLength 
        )

        for (let key in this.textures)
        {
            this.textures[key].format = THREE.RedFormat
            this.textures[key].type = THREE.UnsignedByteType     
            this.textures[key].wrapS = THREE.ClampToEdgeWrapping
            this.textures[key].wrapT = THREE.ClampToEdgeWrapping
            this.textures[key].wrapR = THREE.ClampToEdgeWrapping
            this.textures[key].minFilter = THREE.LinearFilter
            this.textures[key].magFilter = THREE.LinearFilter
            this.textures[key].unpackAlignment = 1
            this.textures[key].needsUpdate = true
        }    
    }

    setGeometry()
    {
        this.geometry = new THREE.BoxGeometry(...this.parameters.geometry.size.toArray())
        this.geometry.translate(...this.parameters.geometry.translation.toArray()) // to align model and texel coordinates
    }

    setMaterial()
    {
        this.material = new ISOMaterial()

        this.material.uniforms.u_volume.value.voxel.fromArray(this.resource.volume.dimensions.map((x) => 1/x))
        this.material.uniforms.u_volume.value.dimensions.fromArray(this.resource.volume.dimensions)
        this.material.uniforms.u_volume.value.size.fromArray(this.resource.volume.size)

        this.material.uniforms.u_sampler.value.volume = this.textures.volume
        this.material.uniforms.u_sampler.value.mask = this.textures.mask
        this.material.uniforms.u_sampler.value.colormap = this.colormaps    
        this.material.uniforms.u_sampler.value.noise = this.noisemaps.white256
    }

    setMesh()
    {
        this.mesh = new THREE.Mesh(this.geometry, this.material)
        this.mesh.position.copy(this.parameters.volume.size).multiplyScalar(- 0.5)
        this.scene.add(this.mesh)
    }
}