
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps'
import { throttleByCalls, throttleByDelay } from '../../Utils/Throttle'

export default class DEBUGGui
{
    constructor(viewer)
    {
        this.viewer = viewer
        this.debug = this.viewer.debug

        // setup
        if (this.debug.active)
        {
            this.addFolders()
            this.addSubfolders()
            this.addControllers()
        }
    }

    addFolders()
    {
        this.folders = {}
        this.folders.viewer = this.debug.ui.addFolder('DEBUGViewer').open()
    }

    addSubfolders()
    {
        this.subfolders          = {}
        this.subfolders.rendering = this.folders.viewer.addFolder('rendering').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.shading  = this.folders.viewer.addFolder('shading').close()
        this.subfolders.lighting = this.folders.viewer.addFolder('lighting').close()
        this.subfolders.debugging = this.folders.viewer.addFolder('debugging').close()

        this.addToggles()            
    }

    addToggles()
    {
        const subfolders = Object.values(this.subfolders)

        const closeOtherFolders = (openFolder) => 
        {
            subfolders.forEach((folder) => 
            {
                if (folder !== openFolder && !folder._closed) folder.close()
            })
        }

        subfolders.forEach((folder) => 
        {
            folder.onOpenClose((openFolder) => 
            {
                if (!openFolder._closed) closeOtherFolders(openFolder)
            })
        })
    }

    // controllers
    
    addControllers()
    {
        this.controllers = {}
        this.addControllersRendering() 
        this.addControllersColormap() 
        this.addControllersShading() 
        this.addControllersLighting() 
        this.addControllersDebugging() 
        
        // this.setBindings()  
    }

    addControllersRendering() 
    {
        const folder = this.subfolders.rendering
        const material = this.viewer.material
        const uRendering = this.viewer.material.uniforms.u_rendering.value
        const uDistmap = this.viewer.material.uniforms.u_distmap.value
        const defines = this.viewer.material.defines
        const objects = { 
            threshold_value            : uRendering.threshold_value,
            sub_division               : uDistmap.sub_division,
            INTERSECT_BBOX_ENABLED     : Boolean(defines.INTERSECT_BBOX_ENABLED),
            INTERSECT_BVOL_ENABLED     : Boolean(defines.INTERSECT_BVOL_ENABLED),
            REFINE_INTERSECTION_ENABLED: Boolean(defines.REFINE_INTERSECTION_ENABLED),
            REFINE_GRADIENTS_ENABLED   : Boolean(defines.REFINE_GRADIENTS_ENABLED),
            DITHERING_ENABLED          : Boolean(defines.DITHERING_ENABLED),
            SKIPPING_ENABLED           : Boolean(defines.SKIPPING_ENABLED),
        }
    
        this.controllers.rendering = 
        {
            thresholdValue     : folder.add(objects, 'threshold_value').min(0).max(1).step(0.0001).onFinishChange((value) => { uRendering.threshold_value = value, this.viewer.updateBoundingBox(),  this.viewer.updateDistanceMap() }),
            minStepScale       : folder.add(uRendering, 'min_step_scaling').min(0.001).max(5).step(0.001),
            maxStepScale       : folder.add(uRendering, 'max_step_scaling').min(0.001).max(5).step(0.001),
            maxStepCount       : folder.add(uRendering, 'max_step_count').min(0).max(1000).step(1),
            maxSkipCount       : folder.add(uRendering, 'max_skip_count').min(0).max(200).step(1),
            subDivision        : folder.add(objects, 'sub_division').min(2).max(16).step(1).onFinishChange((value) => { uDistmap.sub_division = value, this.viewer.updateDistanceMap() }),
            enableIntersectBbox: folder.add(objects, 'INTERSECT_BBOX_ENABLED').name('enable_intersect_bbox').onFinishChange((value) => { defines.INTERSECT_BBOX_ENABLED = Number(value), material.needsUpdate = true }),
            enableIntersectBvol: folder.add(objects, 'INTERSECT_BVOL_ENABLED').name('enable_intersect_bvol').onFinishChange((value) => { defines.INTERSECT_BVOL_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefineInter  : folder.add(objects, 'REFINE_INTERSECTION_ENABLED').name('enable_refine_position').onFinishChange((value) => { defines.REFINE_INTERSECTION_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefineGrad   : folder.add(objects, 'REFINE_GRADIENTS_ENABLED').name('enable_refine_gradient').onFinishChange((value) => { defines.REFINE_GRADIENTS_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping     : folder.add(objects, 'SKIPPING_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.SKIPPING_ENABLED = Number(value), material.needsUpdate = true }),
            enableDithering    : folder.add(objects, 'DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
        }
    }

    addControllersColormap() 
    {
        const folder = this.subfolders.colormap
        const uniforms = this.viewer.material.uniforms.u_colormap.value
        const objects = { flip: false }
    
        this.controllers.colormap = 
        {
            name        : folder.add(uniforms, 'name').options(Object.keys(colormapLocations)).onChange(() => this.updateColormap()),
            minThreshold: folder.add(uniforms.thresholds, 'x').name('min_threshold').min(0).max(1).step(0.001),
            maxThreshold: folder.add(uniforms.thresholds, 'y').name('max_threshold').min(0).max(1).step(0.001),
            levels      : folder.add(uniforms, 'levels').min(1).max(255).step(1),
            flip        : folder.add(objects, 'flip').onChange(() => this.flipColormap())
        }

    }
    
    addControllersShading() 
    {
        const folder = this.subfolders.shading
        const uniforms = this.viewer.material.uniforms.u_shading.value

        this.controllers.shading = 
        {
            ambientReflectance : folder.add(uniforms, 'ambient_reflectance').min(0).max(1).step(0.001),
            diffuseReflectance : folder.add(uniforms, 'diffuse_reflectance').min(0).max(1).step(0.001),
            specularReflectance: folder.add(uniforms, 'specular_reflectance').min(0).max(1).step(0.001),
            shininess          : folder.add(uniforms, 'shininess').min(0).max(40.0).step(0.2),
            edgeContrast       : folder.add(uniforms, 'edge_contrast').min(0).max(1).step(0.001),
        }
    }

    addControllersLighting() 
    {
        const folder = this.subfolders.lighting
        const uniforms = this.viewer.material.uniforms.u_lighting.value

        this.controllers.lighting = 
        {
            intensity        : folder.add(uniforms, 'intensity').min(0).max(2.0).step(0.001),
            shadows          : folder.add(uniforms, 'shadows').min(0).max(1.0).step(0.001),
            ambient_color    : folder.addColor(uniforms, 'ambient_color'),
            diffuse_color    : folder.addColor(uniforms, 'diffuse_color'),
            specular_color   : folder.addColor(uniforms, 'specular_color'),
            positionX        : folder.add(uniforms.position_offset, 'x').min(-5).max(5).step(0.01).name('position_x'),
            positionY        : folder.add(uniforms.position_offset, 'y').min(-5).max(5).step(0.01).name('position_y'),
            positionZ        : folder.add(uniforms.position_offset, 'z').min(-5).max(5).step(0.01).name('position_z'),
        }
    }
    
    addControllersDebugging()
    {
        const folder = this.subfolders.debugging
        const uniforms = this.viewer.material.uniforms.u_debugging.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const objects = { DISCARDING_DISABLED: Boolean(defines.DISCARDING_DISABLED) }

        this.controllers.debugging = 
        {
            option: folder.add(uniforms, 'option').options({ 
                default                 : 0,

                ray_discarded           : 101,
                ray_step_direction      : 102,
                ray_step_distance       : 103,
                ray_rand_distance       : 104,
                ray_start_distance      : 105,
                ray_end_distance        : 106,
                ray_span_distance       : 107,
                ray_start_position      : 108,
                ray_end_position        : 109,
                ray_max_step_count      : 110,
                ray_max_skip_count      : 111,

                trace_intersected       : 201,             
                trace_terminated        : 202,             
                trace_exhausted         : 203,             
                trace_outside           : 204,             
                trace_distance          : 205,             
                trace_position          : 206,             
                trace_derivative        : 207,             
                trace_step_distance     : 208,             
                trace_step_scaling      : 209,             
                trace_step_count        : 210,             
                trace_mean_step_scaling : 211,             
                trace_mean_step_distance: 212,             
                trace_stepped_distance  : 213,             
                trace_skipped_distance  : 214,             
                trace_spanned_distance  : 215,     

                voxel_coords            : 301,         
                voxel_step_coords       : 302,         
                voxel_texture_coords    : 303,         
                voxel_gradient          : 304,         
                voxel_gradient_length   : 305,         
                voxel_value             : 306,         
                voxel_error             : 307,         
                voxel_abs_error         : 308,         

                cell_coords             : 401,
                cell_step_coords        : 402,
                cell_min_position       : 403,
                cell_max_position       : 404,
                cell_entry_distance     : 405,
                cell_exit_distance      : 406,
                cell_distances          : 407,
                cell_values             : 408,
                cell_coeffs             : 409,

                block_value             : 501,
                block_occupied          : 502,
                block_coords            : 503,
                block_step_coords       : 504,
                block_min_position      : 505,
                block_max_position      : 506,
                block_skip_count        : 507,

                frag_depth              : 601,     
                frag_position           : 602,     
                frag_normal_vector      : 603,     
                frag_view_vector        : 604,     
                frag_light_vector       : 605,     
                frag_halfway_vector     : 606,     
                frag_view_angle         : 607,     
                frag_light_angle        : 608,     
                frag_halfway_angle      : 609,     
                frag_camera_angle       : 610,     
                frag_mapped_value       : 611,     
                frag_mapped_color       : 612,     
                frag_ambient_color      : 613,     
                frag_diffuse_color      : 614,     
                frag_specular_color     : 615,     
                frag_shaded_color       : 616,     
                frag_shaded_luminance   : 617,     

                box_entry_distance      : 701,
                box_exit_distance       : 702,
                box_span_distance       : 703,
                box_entry_position      : 704,
                box_exit_position       : 705,
                box_min_entry_distance  : 706,
                box_max_exit_distance   : 707,
                box_max_span_distance   : 708,

                camera_position         : 801,
                camera_direction        : 802,
                camera_far_distance     : 803,
                camera_near_distance    : 804,
                
                variable1               : 901,
                variable2               : 902,
                variable3               : 903,
            }),

            variable1 : folder.add(uniforms, 'variable1').min(-2).max(2).step(0.00000001),
            variable2 : folder.add(uniforms, 'variable2').min(0).max(256).step(0.00000001),
            variable3 : folder.add(uniforms, 'variable3').min(0).max(10).step(1),
            discarding: folder.add(objects, 'DISCARDING_DISABLED').name('disable_discarding').onFinishChange((value) => { defines.DISCARDING_DISABLED = Number(value), material.needsUpdate = true }),
        }
    }
    
    // controllers bindings

    setBindings()
    {
    
        // rendering threshold controller
        this.controllers.rendering.threshold
        .onChange(() => 
        {
            this.displaceColormapLow() // displace colormap low based on rendering threshold
            this.displaceColormapHigh()  // displace colormap high based on rendering threshold
        })

        // cap colormap low based on rendering threshold
        this.controllers.colormap.low.onChange(() => this.capColormapLow())

        // cap colormap high based on rendering threshold
        this.controllers.colormap.high.onChange(() => this.capColormapHigh())

        // cap rendering spacing min based on spacing max
        this.controllers.rendering.steppingMin.onChange(() => this.capRaycastSpacingMin())

        // cap rendering spacing max based on spacing min
        this.controllers.rendering.steppingMax.onChange(() => this.capRaycastSpacingMax())
    }

    capRaycastSpacingMin()
    {
        this.controllers.raycast.steppingMin.setValue
        (
            Math.min
            (
                this.controllers.raycast.steppingMin.getValue(),
                this.controllers.raycast.steppingMax.getValue()
            )
        ).updateDisplay()
    }

    capRaycastSpacingMax()
    {
        this.controllers.rendering.steppingMax.setValue
        (
            Math.max
            (
                this.controllers.rendering.steppingMin.getValue(),
                this.controllers.rendering.steppingMax.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapLow()
    {
        this.controllers.colormap.low.setValue
        (
            Math.min
            (
                this.controllers.colormap.low.getValue(), 
                this.controllers.rendering.sampleThreshold.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapHigh()
    {
        this.controllers.colormap.high.setValue
        (
            Math.max
            (
                this.controllers.rendering.sampleThreshold.getValue(),
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    capColormapLow()
    {
        this.controllers.colormap.low.setValue
        (
            Math.min
            (
                this.controllers.colormap.low.getValue(),            
                this.controllers.rendering.sampleThreshold.getValue(),
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    capColormapHigh()
    {
        this.controllers.colormap.high.setValue
        (
            Math.max
            (
                this.controllers.colormap.low.getValue(), 
                this.controllers.rendering.sampleThreshold.getValue(), 
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    flipColormap()
    {
        // let colormap = this.viewer.material.uniforms.u_colormap.value
        [this.viewer.material.uniforms.u_colormap.value.start_coords.x, this.viewer.material.uniforms.u_colormap.value.end_coords.x] = 
        [this.viewer.material.uniforms.u_colormap.value.end_coords.x, this.viewer.material.uniforms.u_colormap.value.start_coords.x]      
    }

    updateColormap()
    {
        let { x_start, x_end, y } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.u_colormap.value.start_coords.set(x_start, y)
        this.viewer.material.uniforms.u_colormap.value.end_coords.set(x_end, y)      
    }

    destroy() {

        // Dispose of controllers
        Object.values(this.controllers).forEach(group => {
            Object.values(group).forEach(controller => {
                controller.remove()
            })
        })
    
        // Dispose of subfolders
        Object.values(this.subfolders).forEach(subfolder => {
            subfolder.close();
            subfolder.destroy()
        })
    
        // Dispose of folders
        Object.values(this.folders).forEach(folder => {
            folder.close()
            folder.destroy()
        })
    
    
        // Clear references
        this.controllers = null
        this.subfolders = null
        this.folders = null
        this.debug = null
        this.viewer = null
    }
    
}
