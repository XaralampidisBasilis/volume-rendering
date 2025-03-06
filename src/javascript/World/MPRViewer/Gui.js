
import { colormapLocations } from '@textures/colormaps/colormaps'

export default class Gui
{
    constructor(viewer)
    {
        this.viewer = viewer
        this.debug = this.viewer.debug

        // setup
        if (this.debug.active)
        {
            this.setFolders()
            this.setControllers()
        }
    }

    setFolders()
    {
        this.folders = {}
        this.subfolders = {}

        this.folders.viewer = this.debug.ui.addFolder('MPRViewer').open()

        this.subfolders.rendering = this.folders.viewer.addFolder('rendering').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.debugging = this.folders.viewer.addFolder('debugging').close()
        this.setOpenClose()
    }

    setOpenClose()
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
    
    setControllers()
    {
        this.controllers = {}
        this.setControllersRendering() 
        // this.setControllersColormap() 
        this.setControllersDebugging() 
    }

    setControllersRendering() 
    {
        const folder = this.subfolders.rendering
        const size = this.viewer.processor.intensityMap.parameters.size.clone() 
        this.controllers.rendering = 
        {
            x : folder.add(this.viewer.slices.position, 'x').min(0).max(size.x).step(0.0001).onChange(() => this.viewer.slices.update()),
            y : folder.add(this.viewer.slices.position, 'y').min(0).max(size.y).step(0.0001).onChange(() => this.viewer.slices.update()),
            z : folder.add(this.viewer.slices.position, 'z').min(0).max(size.z).step(0.0001).onChange(() => this.viewer.slices.update()),
            slicesVisible : folder.add(this.viewer.slices, 'visible').name('slicesVisible'),
            surfaceVisible : folder.add(this.viewer.surface, 'visible').name('surfaceVisible'),
        }
    }

    setControllersColormap() 
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
    
    setControllersDebugging()
    {
        const folder = this.subfolders.debugging
        const material = this.viewer.surface.material
        const uniforms = material.uniforms.u_debugging.value
        const defines = material.defines
        const objects = { DISCARDING_DISABLED: Boolean(defines.DISCARDING_DISABLED) }

        this.controllers.debugging = 
        {
            option: folder.add(uniforms, 'option').options({ 
                default                 : 0,
                
                ray_discarded           : 101,
                ray_direction           : 102,
                ray_spacing             : 103,
                ray_start_distance      : 104,
                ray_end_distance        : 105,
                ray_span_distance       : 106,
                ray_start_position      : 107,
                ray_end_position        : 108,
                
                trace_terminated        : 201,
                trace_intersected       : 202,
                trace_exhausted         : 203,
                trace_outside           : 204,
                trace_distance          : 205,
                trace_position          : 206,
                trace_intensity         : 207,
                trace_gradient          : 208,
                trace_gradient_length   : 209,
                
                voxel_occupied          : 301,
                voxel_intersected       : 302,
                voxel_terminated        : 303,
                voxel_cheby_distance    : 304,
                voxel_coords            : 305,
                voxel_coords_step       : 306,
                voxel_max_position      : 307,
                voxel_min_position      : 308,
                voxel_entry_distance    : 309,
                voxel_exit_distance     : 310,
                voxel_span_distance     : 311,

                frag_depth              : 401,
                frag_position           : 402,
                frag_normal_vector      : 403,
                frag_view_vector        : 404,
                frag_light_vector       : 405,
                frag_halfway_vector     : 406,
                frag_view_angle         : 407,
                frag_light_angle        : 408,
                frag_halfway_angle      : 409,
                frag_color              : 410,
                frag_ambient_color      : 411,
                frag_diffuse_color      : 412,
                frag_specular_color     : 413,
                frag_luminance          : 414,

                box_entry_distance      : 501,
                box_exit_distance       : 502,
                box_span_distance       : 503,
                box_entry_position      : 504,
                box_exit_position       : 505,

                camera_position         : 601,

                stats_num_fetches       : 701,
                stats_num_steps         : 702,
                stats_num_skips         : 703,
                
                variable1               : 801,
                variable2               : 802,
                variable3               : 803,
            }),

            variable1 : folder.add(uniforms, 'variable1').min(-2).max(2).step(0.00000001),
            variable2 : folder.add(uniforms, 'variable2').min(0).max(256).step(0.00000001),
            variable3 : folder.add(uniforms, 'variable3').min(0).max(10).step(1),
            maxVoxels : folder.add(uniforms, 'max_voxels').min(0).max(defines.MAX_VOXELS).step(1),
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
