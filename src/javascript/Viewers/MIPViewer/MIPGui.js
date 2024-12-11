
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
        const uExtremap = this.viewer.material.uniforms.u_extremap.value
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
            subDivision        : folder.add(uExtremap, 'sub_division').min(2).max(16).step(1).onFinishChange((value) => { uExtremap.sub_division = value, this.viewer.updateExtremaMap() }),
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
               frag_view_angle         : 17,
               frag_camera_angle       : 18,
               frag_mapped_value       : 19,
               frag_mapped_color       : 20,
               ray_discarded           : 21,
               ray_step_direction      : 22,
               ray_step_distance       : 23,
               ray_rand_distance       : 24,
               ray_start_distance      : 25,
               ray_end_distance        : 26,
               ray_span_distance       : 27,
               ray_start_position      : 28,
               ray_end_position        : 29,
               ray_max_step_count      : 30,
               ray_max_skip_count      : 31,
               ray_min_value           : 32,
               ray_max_value           : 33,
               trace_terminated        : 34,
               trace_exhausted         : 35,
               trace_distance          : 36,
               trace_outside           : 37,
               trace_position          : 38,
               trace_error             : 39,
               trace_abs_error         : 40,
               trace_derivative        : 41,
               trace_step_distance     : 42,
               trace_step_scaling      : 43,
               trace_step_count        : 44,
               trace_mean_step_scaling : 45,
               trace_mean_step_distance: 46,
               trace_stepped_distance  : 47,
               trace_skipped_distance  : 48,
               trace_spanned_distance  : 49,
               voxel_coords            : 50,
               voxel_texture_coords    : 51,
               voxel_gradient          : 52,
               voxel_gradient_length   : 53,
               voxel_value             : 54,
               block_min_value         : 55,
               block_max_value         : 56,
               block_occupied          : 57,
               block_coords            : 58,
               block_skip_count        : 59,
               debug_variable1         : 60,
               debug_variable2         : 61,
               debug_variable3         : 62,
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
