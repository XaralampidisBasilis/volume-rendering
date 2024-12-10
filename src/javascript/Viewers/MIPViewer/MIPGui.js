
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps'
import { throttleByCalls, throttleByDelay } from '../../Utils/Throttle'

export default class MIPGui
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
        this.folders.viewer = this.debug.ui.addFolder('MIPViewer').open()
    }

    addSubfolders()
    {
        this.subfolders          = {}
        this.subfolders.rendering = this.folders.viewer.addFolder('rendering').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.shading  = this.folders.viewer.addFolder('shading').close()
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
            min_value                  : uRendering.min_value,
            INTERSECT_BVOL_ENABLED     : Boolean(defines.INTERSECT_BVOL_ENABLED),
            REFINE_INTERSECTION_ENABLED: Boolean(defines.REFINE_INTERSECTION_ENABLED),
            DITHERING_ENABLED          : Boolean(defines.DITHERING_ENABLED),
            SKIPPING_ENABLED           : Boolean(defines.SKIPPING_ENABLED),
        }
    
        this.controllers.rendering = 
        {
            minStepScale       : folder.add(uRendering, 'min_step_scaling').min(0.001).max(5).step(0.001),
            maxStepScale       : folder.add(uRendering, 'max_step_scaling').min(0.001).max(5).step(0.001),
            maxStepCount       : folder.add(uRendering, 'max_step_count').min(0).max(1000).step(1),
            maxSkipCount       : folder.add(uRendering, 'max_skip_count').min(0).max(200).step(1),
            subDivision        : folder.add(uDistmap, 'sub_division').min(2).max(16).step(1).onFinishChange((value) => { uDistmap.sub_division = value, this.viewer.updateDistmap() }),
            enableIntersectBvol: folder.add(objects, 'INTERSECT_BVOL_ENABLED').name('enable_intersect_bvol').onFinishChange((value) => { defines.INTERSECT_BVOL_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefineInter  : folder.add(objects, 'REFINE_INTERSECTION_ENABLED').name('enable_refine_position').onFinishChange((value) => { defines.REFINE_INTERSECTION_ENABLED = Number(value), material.needsUpdate = true }),
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
            shininess          : folder.add(uniforms, 'shininess').min(0).max(40.0).step(0.2),
            edgeContrast       : folder.add(uniforms, 'edge_contrast').min(0).max(1).step(0.001),
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
                box_entry_distance      : 1,
                box_exit_distance       : 2,
                box_span_distance       : 3,
                box_entry_position      : 4,
                box_exit_position       : 5,
                box_min_entry_distance  : 6,
                box_max_exit_distance   : 7,
                box_max_span_distance   : 8,
                camera_position         : 9,
                camera_direction        : 10,
                camera_far_distance     : 11,
                camera_near_distance    : 12,
                frag_depth              : 13,
                frag_position           : 14,
                frag_normal_vector      : 15,
                frag_view_vector        : 16,
                frag_light_vector       : 17,
                frag_halfway_vector     : 18,
                frag_view_angle         : 19,
                frag_light_angle        : 20,
                frag_halfway_angle      : 21,
                frag_camera_angle       : 22,
                frag_mapped_value       : 23,
                frag_mapped_color       : 24,
                frag_ambient_color      : 25,
                frag_diffuse_color      : 26,
                frag_specular_color     : 27,
                frag_shaded_color       : 28,
                frag_shaded_luminance   : 29,
                ray_discarded           : 30,
                ray_step_direction      : 31,
                ray_step_distance       : 32,
                ray_rand_distance       : 33,
                ray_start_distance      : 34,
                ray_end_distance        : 35,
                ray_span_distance       : 36,
                ray_start_position      : 37,
                ray_end_position        : 38,
                ray_max_step_count      : 39,
                ray_max_skip_count      : 40,
                trace_intersected       : 41,
                trace_terminated        : 42,
                trace_exhausted         : 43,
                trace_distance          : 44,
                trace_outside           : 45,
                trace_position          : 46,
                trace_error             : 47,
                trace_abs_error         : 48,
                trace_derivative        : 49,
                trace_delta_distance    : 50,
                trace_step_distance     : 51,
                trace_step_scaling      : 52,
                trace_step_stretching   : 53,
                trace_step_count        : 54,
                trace_mean_step_scaling : 55,
                trace_mean_step_distance: 56,
                trace_stepped_distance  : 57,
                trace_skipped_distance  : 58,
                trace_spanned_distance  : 59,
                voxel_coords            : 60,
                voxel_texture_coords    : 61,
                voxel_gradient          : 62,
                voxel_gradient_length   : 63,
                voxel_value             : 64,
                block_value             : 65,
                block_occupied          : 66,
                block_coords            : 67,
                block_skip_count        : 68,
                debug_variable1         : 69,
                debug_variable2         : 70,
                debug_variable3         : 71,
            }),

            variable1 : folder.add(uniforms, 'variable1').min(-2).max(2).step(0.00000001),
            variable2 : folder.add(uniforms, 'variable2').min(0).max(256).step(0.00000001),
            variable3 : folder.add(uniforms, 'variable3').min(0).max(10).step(1),
            discarding: folder.add(objects, 'DISCARDING_DISABLED').name('discarding').onFinishChange((value) => { defines.DISCARDING_DISABLED = Number(value), material.needsUpdate = true }),
        }
    }
    
    // controllers bindings

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
