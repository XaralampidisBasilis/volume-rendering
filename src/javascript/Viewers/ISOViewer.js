import * as THREE from 'three'
import { TransformControls } from 'three/examples/jsm/controls/TransformControls.js'
import Experience from '../Experience.js'
import ISOMaterial from '../Materials/ISOMaterial.js'
import ISOGui from '../Gui/ISOGui.js'
import GPUOccupancy from '../Computes/GPUOccupancy.js'

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

        this.setNoisemaps()
        this.setColormaps()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
        // this.setOccupancy()

        // Debug gui
        if (this.debug.active) 
        {
            // this.gui = new ISOGui(this.debug, this)
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
        this.geometry = new THREE.BoxGeometry( 
            this.resource.volume.size[0] + this.resource.volume.spacing[0], 
            this.resource.volume.size[1] + this.resource.volume.spacing[1],
            this.resource.volume.size[2] + this.resource.volume.spacing[2]
        )

        // to align model and texel coordinates
        this.geometry.translate( 
            this.resource.volume.size[0] / 2 - this.resource.volume.spacing[0] / 2, 
            this.resource.volume.size[1] / 2 - this.resource.volume.spacing[1] / 2, 
            this.resource.volume.size[2] / 2 - this.resource.volume.spacing[2] / 2 
        )
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
        this.mesh.position.x = - this.resource.volume.size[0] * 0.5
        this.mesh.position.y = - this.resource.volume.size[1] * 0.5
        this.mesh.position.z = - this.resource.volume.size[2] * 0.5
        this.scene.add(this.mesh)
    }

    setOccupancy()
    {        
        this.occupancy = new GPUOccupancy(this.material.uniforms.u_occupancy.value.resolution, this.textures.volume, this.renderer.instance, this.scene)
        this.occupancy.compute(this.material.uniforms.u_raycast.value.threshold) 

        this.material.uniforms.u_occupancy.value.size = this.occupancy.sizes.occupancy
        this.material.uniforms.u_occupancy.value.block = this.occupancy.sizes.block
        this.material.uniforms.u_sampler.value.occupancy = this.occupancy.map     

        if (this.debug.active)
            this.occupancy.debug(this.viewer.scene)
    }

}