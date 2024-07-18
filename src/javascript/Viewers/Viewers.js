import * as THREE from 'three'
import Experience from '../Experience'
import ViewerMaterial from '../Materials/ViewerMaterial'
import { TransformControls } from 'three/examples/jsm/controls/TransformControls'

export default class Viewer
{
    constructor()
    {
        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.time = this.experience.time
        this.debug = this.experience.debug

        // Debug
        if(this.debug.active)
        {
            this.debugFolder = this.debug.ui.addFolder('volume')
        }

        // Resource
        this.resource = {}        
        this.resource.volume = this.resources.items.lungVolume
        this.resource.mask = this.resources.items.lungMask

        this.setColormaps()
        this.setTextures()
        this.setGeometry()
        this.setMaterial()
        this.setMesh()
    }

    setColormaps()
    {
        this.colormaps = {}

        this.colormaps.gray = this.resources.items.grayColormap
        this.colormaps.viridis = this.resources.items.viridisColormap
    }

    setTextures()
    {
        this.textures = {}

        // Volume

        this.textures.volume = new THREE.Data3DTexture( 
            this.resource.volume.data, 
            this.resource.volume.xLength, 
            this.resource.volume.yLength,
            this.resource.volume.zLength 
        )
        this.textures.volume.format = THREE.RedFormat
        this.textures.volume.type = THREE.FloatType
        this.textures.volume.minFilter = THREE.NearestFilter
        this.textures.volume.magFilter = THREE.NearestFilter
        this.textures.volume.unpackAlignment = 1
        this.textures.volume.needsUpdate = true

        // Mask

        this.textures.mask = new THREE.Data3DTexture( 
            this.resource.mask.data, 
            this.resource.mask.xLength, 
            this.resource.mask.yLength,
            this.resource.mask.zLength 
        )
        this.textures.mask.format = THREE.RedFormat
        this.textures.mask.type = THREE.UnsignedByteType
        this.textures.mask.minFilter = THREE.NearestFilter
        this.textures.mask.magFilter = THREE.NearestFilter
        this.textures.mask.unpackAlignment = 1
        this.textures.mask.needsUpdate = true

    }

    setGeometry()
    {
        this.geometry = new THREE.BoxGeometry( 
            this.resource.volume.RSAdimensions[0], 
            this.resource.volume.RSAdimensions[1], 
            this.resource.volume.RSAdimensions[2] 
        )

        // geometry.translate( 
        //     this.resource.volume.RSAdimensions[0] / 2 - this.resource.volume.spacing[0], 
        //     this.resource.volume.RSAdimensions[1] / 2 - this.resource.volume.spacing[1], 
        //     this.resource.volume.RSAdimensions[2] / 2 - this.resource.volume.spacing[2] 
        // )
    }

    setMaterial()
    {
        this.material = new ViewerMaterial()
    }

    setMesh()
    {

    }

  
}