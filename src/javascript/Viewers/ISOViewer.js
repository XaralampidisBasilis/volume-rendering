import * as THREE from 'three'
import { TransformControls } from 'three/examples/jsm/controls/TransformControls.js'
import { colormaps } from '../../../static/textures/colormaps/colormaps.js'
import Experience from '../Experience.js'
import ISOMaterial from '../Materials/ISOMaterial.js'
import GPUOccupancy from '../Computes/GPUOccupancy.js'
import { throttleByCalls } from '../Utils/throttle.js'

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
        this.setOccupancy()
        this.setControls()
        this.setControlBindings()
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
        
        this.material.uniforms.u_volume_voxel.value.fromArray(this.resource.volume.dimensions.map((x) => 1/x))
        this.material.uniforms.u_volume_dimensions.value.fromArray(this.resource.volume.dimensions)
        this.material.uniforms.u_volume_size.value.fromArray(this.resource.volume.size)
        this.material.uniforms.u_volume_data.value = this.textures.volume
        this.material.uniforms.u_volume_mask.value = this.textures.mask
        this.material.uniforms.u_colormap_data.value = this.colormaps    
        this.material.uniforms.u_raycast_noise.value = this.noisemaps.white256
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
        this.occupancy = new GPUOccupancy(this.material.uniforms.u_occupancy_resolution.value, this.textures.volume, this.renderer.instance)
        this.occupancy.setThreshold(this.material.uniforms.u_raycast_threshold.value)
        this.occupancy.update() 

        this.material.uniforms.u_occupancy_size.value = this.occupancy.sizes.occupancy
        this.material.uniforms.u_occupancy_block.value = this.occupancy.sizes.block.clone().divide(this.occupancy.sizes.volume)
        this.material.uniforms.u_occupancy_data.value = this.occupancy.getTexture()       

        if(this.debug.active)
            this.scene.add(this.occupancy.gpgpu.debug)
    }

    setControls()
    {        
        if(this.debug.active)
        {          
            // folders
            const viewerFolder = this.debug.ui.addFolder('Viewer').open()
            const raycastFolder = viewerFolder.addFolder('raycast').close()
            const gradientFolder = viewerFolder.addFolder('gradient').close()
            const colormapFolder = viewerFolder.addFolder('colormap').close()
            const lightingFolder = viewerFolder.addFolder('lighting').close()   
            const occupancyFolder = viewerFolder.addFolder('occupancy').close()   

            // close other folders when opening one
            const folders = [raycastFolder, gradientFolder, colormapFolder, lightingFolder, occupancyFolder];

            const closeOtherFolders = (openFolder) => {

                folders.forEach(folder => 
                {
                    if (folder !== openFolder)
                        folder.close()
                })
            }
    
            folders.forEach((folder) => 
            {
                folder.onOpenClose((openFolder) => 
                {
                    if (!openFolder._closed)
                        closeOtherFolders(openFolder)
                })
            })

            // controls
            const setControlsRaycast = (folder) => 
            {                
                folder
                    .add(this.material.uniforms.u_raycast_threshold, 'value')
                    .name('threshold')
                    .min(0)
                    .max(0.5)
                    .step(0.0001) 
    
                folder
                    .add(this.material.uniforms.u_raycast_resolution, 'value')
                    .name('resolution')
                    .min(0.25)
                    .max(2)
                    .step(0.001)
                    
                folder
                    .add(this.material.uniforms.u_raycast_refinements, 'value')
                    .name('refinements')
                    .min(0)
                    .max(5)
                    .step(1)
                                        
                folder
                    .add(this.material.uniforms.u_raycast_dither, 'value')
                    .name('dither')      
            }

            const setControlsGradient = (folder) =>
            {    
                folder
                    .add(this.material.uniforms.u_gradient_resolution, 'value')
                    .name('resolution')
                    .min(0.25)
                    .max(2)
                    .step(0.001)
    
                folder
                    .add(this.material.uniforms.u_gradient_method, 'value')
                    .name('method')
                    .options({ sobel: 1, central: 2, tetrahedron: 3})                            
            }

            const setControlsColormap = (folder) => 
            {
                const object = { flip: false}
               
                folder
                    .add(this.material.uniforms.u_colormap_u_lim.value, 'x')
                    .name('low')
                    .min(0)
                    .max(1)
                    .step(0.001)       
    
                folder
                    .add(this.material.uniforms.u_colormap_u_lim.value, 'y')
                    .name('high')
                    .min(0)
                    .max(1)
                    .step(0.001)               
    
                folder        
                    .add(this.material.uniforms.u_colormap_name, 'value')
                    .name('name')
                    .options(Object.keys(colormaps))  
                    .onChange((name) => 
                    {
                        let { v, u_start, u_end } = colormaps[name]
                        this.material.uniforms.u_colormap_v.value = v
                        this.material.uniforms.u_colormap_u_range.value.set(u_start, u_end)                
                    })
                                      
                folder
                    .add(object, 'flip')
                    .name('flip')
                    .onChange(() => 
                    {    
                        [this.material.uniforms.u_colormap_u_range.value.y, this.material.uniforms.u_colormap_u_range.value.x] = 
                        [this.material.uniforms.u_colormap_u_range.value.x, this.material.uniforms.u_colormap_u_range.value.y]                    
                    })
                
            }

            const setControlsLighting = (folder) =>
            {    
                folder
                    .add(this.material.uniforms.u_lighting_ka, 'value')
                    .name('Ka')
                    .min(0)
                    .max(1)
                    .step(0.001) 
    
                folder
                    .add(this.material.uniforms.u_lighting_kd, 'value')
                    .name('Kd')
                    .min(0)
                    .max(1)
                    .step(0.001)
                
                folder
                    .add(this.material.uniforms.u_lighting_ks, 'value')
                    .name('Ks')
                    .min(0)
                    .max(1)
                    .step(0.001)
    
                folder
                    .add(this.material.uniforms.u_lighting_shininess, 'value')
                    .name('shininess')
                    .min(0)
                    .max(40.0)
                    .step(0.2) 
    
                folder
                    .add(this.material.uniforms.u_lighting_power, 'value')
                    .name('power')
                    .min(0)
                    .max(2.0)
                    .step(0.1)
    
                folder
                    .add(this.material.uniforms.u_lighting_mode, 'value')
                    .name('mode')
                    .options({ phong: 1, blinn: 2})
    
                folder
                    .add(this.material.uniforms.u_lighting_attenuate, 'value')
                    .name('attenuate')                    
          
            }

            const setControlsOccupancy = (folder) =>
            {
                const object = { visible: true}

                folder
                    .add(this.material.uniforms.u_occupancy_resolution, 'value')
                    .name('blocks')
                    .min(2)
                    .max(64)
                    .step(1) 

                folder
                    .add(object, 'visible')
                    .name('visible')
                    .onChange((visible) => 
                    {  
                        if(this.debug.active)
                            this.occupancy.gpgpu.debug.material.visible = visible
                    })
            }

            setControlsRaycast(raycastFolder)
            setControlsGradient(gradientFolder)
            setControlsColormap(colormapFolder)
            setControlsLighting(lightingFolder)    
            setControlsOccupancy(occupancyFolder)
        }
    }

    setControlBindings()
    {
        if(this.debug.active)
        {          
            // folders
            const viewerFolder = this.debug.getFolder(this.debug.ui, 'Viewer')
            const raycastFolder = this.debug.getFolder(viewerFolder, 'raycast')
            const colormapFolder = this.debug.getFolder(viewerFolder, 'colormap')
            const lightingFolder = this.debug.getFolder(viewerFolder, 'lighting')
            const occupancyFolder = this.debug.getFolder(viewerFolder, 'occupancy')

            // controllers
            const thresholdController = this.debug.getController(raycastFolder, 'threshold')
            const lowController = this.debug.getController(colormapFolder, 'low')
            const highController = this.debug.getController(colormapFolder, 'high')
            const powerController = this.debug.getController(lightingFolder, 'power')
            const attenuateController = this.debug.getController(lightingFolder, 'attenuate')
            const blocksController = this.debug.getController(occupancyFolder, 'blocks')
            
            // updates
            const updateOccupancy = (threshold) => {

                this.occupancy.setThreshold(threshold)
                this.occupancy.update()
                this.material.uniforms.u_occupancy_data.value = this.occupancy.getTexture()

            }

            const updateOccupancyThrottled = throttleByCalls(updateOccupancy, 5);

            
            // Raycast threshold

            thresholdController
                .onChange((threshold) => 
                {
                    // low <= threshold
                    lowController
                        .setValue(Math.min(lowController.getValue(), threshold))
                        .updateDisplay()
                    
                    // threshold <= high
                    highController
                        .setValue(Math.max(threshold, highController.getValue()))
                        .updateDisplay()

                    updateOccupancyThrottled(threshold)       
                })
                .onFinishChange((threshold) => 
                {
                    updateOccupancy(threshold)

                    this.occupancy.readBoundingBox()
                    this.material.uniforms.u_occupancy_box_min.value = this.occupancy.box.min
                    this.material.uniforms.u_occupancy_box_max.value = this.occupancy.box.max
                })


            // Colormap low

            lowController
                .onChange((low) => 
                {                   
                    lowController 
                        .setValue(Math.min(low, thresholdController.getValue(), highController.getValue()))
                        .updateDisplay()
                })


            // Colormap high

            highController
                .onChange((high) => 
                {             
                    highController 
                        .setValue(Math.max(lowController.getValue(), thresholdController.getValue(), high))
                        .updateDisplay()
                })


            // Lighting attenuation

            attenuateController
                .onChange((attenuate) => 
                {
                    if (attenuate)
                        powerController
                            .min(0)
                            .max(20)
                            .setValue(7)
                            .updateDisplay()
                    else
                        powerController
                            .min(0)
                            .max(2)
                            .setValue(1)
                            .updateDisplay()
                })    

            // Occupancy blocks
                
            blocksController
                .onFinishChange((blocks) =>
                {
                    if (this.debug.active)
                        this.scene.remove(this.occupancy.gpgpu.debug)

                    this.occupancy.dispose()
                    this.setOccupancy()
                })
                
        }
    }
   
    update()
    {
    }

}