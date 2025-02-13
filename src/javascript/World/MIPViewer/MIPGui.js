
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps'
// import { throttleByCalls, throttleByDelay } from '../../Utils/Throttle'

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
        const defines = this.viewer.material.defines
        const uRendering = this.viewer.material.uniforms.u_rendering.value
        const objects = 
        { 
            INTERSECT_BBOX_ENABLED     : Boolean(defines.INTERSECT_BBOX_ENABLED),
            SKIPPING_ENABLED           : Boolean(defines.SKIPPING_ENABLED),
        }
    
        this.controllers.rendering = 
        {
            maxCount           : folder.add(uRendering, 'max_count').min(0).max(100).step(1),
            maxCellCount       : folder.add(uRendering, 'max_cell_count').min(0).max(100).step(1),
            maxBlockCount      : folder.add(uRendering, 'max_block_count').min(0).max(100).step(1),
            enableIntersectBbox: folder.add(objects, 'INTERSECT_BBOX_ENABLED').name('enable_intersect_bbox').onFinishChange((value) => { defines.INTERSECT_BBOX_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping     : folder.add(objects, 'SKIPPING_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.SKIPPING_ENABLED = Number(value), material.needsUpdate = true }),
        }
    }

    addControllersColormap() 
    {
        const folder = this.subfolders.colormap
        const uniforms = this.viewer.material.uniforms.u_color_map.value
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
                ray_direction           : 102,
                ray_step_distance       : 103,
                ray_start_distance      : 104,
                ray_end_distance        : 105,
                ray_span_distance       : 106,
                ray_start_position      : 107,
                ray_end_position        : 108,
                ray_max_cell_count      : 109,
                ray_max_block_count     : 110,
                 
                trace_terminated        : 201,
                trace_exhausted         : 202,
                trace_outside           : 203,
                trace_distance          : 204,
                trace_position          : 205,
                trace_intensity         : 206,
                trace_error             : 207,
                trace_abs_error         : 208,
                trace_gradient          : 209,
                trace_gradient_length   : 210,

                mip_terminated          : 1001,
                mip_exhausted           : 1002,
                mip_outside             : 1003,
                mip_distance            : 1004,
                mip_position            : 1005,
                mip_intensity           : 1006,
                mip_error               : 1007,
                mip_abs_error           : 1008,
                mip_gradient            : 1009,
                mip_gradient_length     : 1010,
                
                cell_intersected        : 401,
                cell_terminated         : 402,
                cell_coords             : 403,
                cell_coords_step        : 404,
                cell_max_position       : 405,
                cell_min_position       : 406,
                cell_entry_distance     : 407,
                cell_exit_distance      : 408,
                cell_span_distance      : 409,
                cell_sample_distances   : 410,
                cell_sample_intensities : 411,
                cell_intensity_coeffs   : 412,

                block_min_intensity     : 501,
                block_max_intensity     : 502,
                block_cheby_distance    : 503,
                block_occupied          : 504,
                block_coords            : 505,
                block_coords_step       : 506,
                block_min_position      : 507,
                block_max_position      : 508,
                block_entry_distance    : 509,
                block_exit_distance     : 510,
                block_entry_position    : 511,
                block_exit_position     : 512,

                frag_depth              : 601,
                frag_position           : 602,
                frag_camera_angle       : 603,
                frag_mapped_intensity   : 604,
                frag_mapped_color       : 605,

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

                stats_num_fetches       : 301,
                stats_num_steps         : 302,
                stats_num_skips         : 303,
                
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

    flipColormap()
    {
        // let colormap = this.viewer.material.uniforms.u_color_map.value
        [this.viewer.material.uniforms.u_color_map.value.start_coords.x, this.viewer.material.uniforms.u_color_map.value.end_coords.x] = 
        [this.viewer.material.uniforms.u_color_map.value.end_coords.x, this.viewer.material.uniforms.u_color_map.value.start_coords.x]      
    }

    updateColormap()
    {
        let { x_start, x_end, y } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.u_color_map.value.start_coords.set(x_start, y)
        this.viewer.material.uniforms.u_color_map.value.end_coords.set(x_end, y)      
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
