
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps'
import { throttleByCalls, throttleByDelay } from '../../Utils/Throttle'

export default class ISOGui
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
        this.folders.viewer = this.debug.ui.addFolder('ISOViewer').open()
    }

    addSubfolders()
    {
        this.subfolders          = {}
        this.subfolders.raymarch = this.folders.viewer.addFolder('raymarch').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.shading  = this.folders.viewer.addFolder('shading').close()
        this.subfolders.lighting = this.folders.viewer.addFolder('lighting').close()
        this.subfolders.debug    = this.folders.viewer.addFolder('debug').close()

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
        this.addControllersRaymarch() 
        this.addControllersColormap() 
        this.addControllersShading() 
        this.addControllersLighting() 
        this.addControllersDebug() 
        
        // this.setBindings()  
    }

    addControllersRaymarch() 
    {
        const folder = this.subfolders.raymarch
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.u_raymarch.value
        const defines = this.viewer.material.defines
        const objects = { 
            sample_threshold                 : 0.0,
            RAY_BBOX_INTERSECTION_ENABLED    : Boolean(defines.RAY_BBOX_INTERSECTION_ENABLED),
            RAY_BVOL_INTERSECTION_ENABLED    : Boolean(defines.RAY_BVOL_INTERSECTION_ENABLED),
            RAY_DITHERING_ENABLED            : Boolean(defines.RAY_DITHERING_ENABLED),
            TRACE_POSITION_REFINEMENT_ENABLED: Boolean(defines.TRACE_POSITION_REFINEMENT_ENABLED),
            TRACE_GRADIENT_REFINEMENT_ENABLED: Boolean(defines.TRACE_GRADIENT_REFINEMENT_ENABLED),
            TRACE_BVH_MARCHING_ENABLED       : Boolean(defines.TRACE_BVH_MARCHING_ENABLED),
            TRACE_STEP_SCALING_ENABLED       : Boolean(defines.TRACE_STEP_SCALING_ENABLED),
            TRACE_STEP_STRETCHING_ENABLED    : Boolean(defines.TRACE_STEP_STRETCHING_ENABLED),
        }
    

        this.controllers.raymarch = 
        {
            sampleThreshold       : folder.add(objects, 'sample_threshold').min(0).max(1).step(0.0001).onFinishChange((value) => { uniforms.sample_threshold = value, this.viewer.updateBoundingBox(value),  this.viewer.updateDistmap(value, 4) }),
            minStepScale          : folder.add(uniforms, 'min_step_scaling').min(0.001).max(5).step(0.001),
            maxStepScale          : folder.add(uniforms, 'max_step_scaling').min(0.001).max(5).step(0.001),
            maxStepCount          : folder.add(uniforms, 'max_step_count').min(0).max(1000).step(1),
            maxSkipCount          : folder.add(uniforms, 'max_skip_count').min(0).max(200).step(1),
            enableBboxIntersection: folder.add(objects, 'RAY_BBOX_INTERSECTION_ENABLED').name('enable_bbox_intersection').onFinishChange((value) => { defines.RAY_BBOX_INTERSECTION_ENABLED = Number(value), material.needsUpdate = true }),
            enableBVolIntersection: folder.add(objects, 'RAY_BVOL_INTERSECTION_ENABLED').name('enable_bvh_intersection').onFinishChange((value) => { defines.RAY_BVOL_INTERSECTION_ENABLED = Number(value), material.needsUpdate = true }),
            enableDithering       : folder.add(objects, 'RAY_DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.RAY_DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
            enablePosRefinement   : folder.add(objects, 'TRACE_POSITION_REFINEMENT_ENABLED').name('enable_position_refinement').onFinishChange((value) => { defines.TRACE_POSITION_REFINEMENT_ENABLED = Number(value), material.needsUpdate = true }),
            enableGradRefinement  : folder.add(objects, 'TRACE_GRADIENT_REFINEMENT_ENABLED').name('enable_gradient_refinement').onFinishChange((value) => { defines.TRACE_GRADIENT_REFINEMENT_ENABLED = Number(value), material.needsUpdate = true }),
            enableBVHMarching     : folder.add(objects, 'TRACE_BVH_MARCHING_ENABLED').name('enable_bvh_marching').onFinishChange((value) => { defines.TRACE_BVH_MARCHING_ENABLED = Number(value), material.needsUpdate = true }),
            enableStepScaling     : folder.add(objects, 'TRACE_STEP_SCALING_ENABLED').name('enable_step_scaling').onFinishChange((value) => { defines.TRACE_STEP_SCALING_ENABLED = Number(value), material.needsUpdate = true }),
            enableStepStretching  : folder.add(objects, 'TRACE_STEP_STRETCHING_ENABLED').name('enable_step_stretching').onFinishChange((value) => { defines.TRACE_STEP_STRETCHING_ENABLED = Number(value), material.needsUpdate = true }),
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
    
    addControllersDebug()
    {
        const folder = this.subfolders.debug
        const uniforms = this.viewer.material.uniforms.u_debugger.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const objects = { FRAGMENT_DISCARDING_DISABLED: Boolean(defines.FRAGMENT_DISCARDING_DISABLED) }

        this.controllers.debug = 
        {
            option: folder.add(uniforms, 'option').options({ 
                default                    : 0,
                frag_depth                 : 1,
                ray_step_direction         : 2,
                ray_step_distance          : 3,
                ray_rand_distance          : 4,
                ray_start_distance         : 5,
                ray_end_distance           : 6,
                ray_span_distance          : 7,
                ray_start_position         : 8,
                ray_end_position           : 9,
                ray_box_start_distance     : 10,
                ray_box_end_distance       : 11,
                ray_box_span_distance      : 12,
                ray_box_start_position     : 13,
                ray_box_end_position       : 14,
                ray_max_step_count         : 15,
                ray_max_skip_count         : 16,
                trace_intersected          : 17,
                trace_terminated           : 18,
                trace_suspended            : 19,
                trace_sample_value         : 20,
                trace_sample_error         : 21,
                trace_sample_abs_error     : 22,
                trace_normal               : 23,
                trace_gradient             : 24,
                trace_gradient_magnitude   : 25,
                trace_derivative           : 26,
                trace_outside              : 27,
                trace_position             : 28,
                trace_distance             : 29,
                trace_distance_error       : 30,
                trace_distance_diff        : 31,
                trace_voxel_coords         : 32,
                trace_skip_distance        : 33,
                trace_step_scaling         : 34,
                trace_step_stretching      : 35,
                trace_min_step_stretching  : 36,
                trace_max_step_stretching  : 37,
                trace_range_step_stretching: 38,
                trace_step_distance        : 39,
                trace_mean_step_scaling    : 40,
                trace_mean_step_distance   : 41,
                trace_spanned_distance     : 42,
                trace_stepped_distance     : 43,
                trace_skipped_distance     : 44,
                trace_step_count           : 45,
                trace_skip_count           : 46,
                trace_total_count          : 47,
                trace_mapped_color         : 48,
                trace_luminance            : 49,
                trace_shaded_color         : 50,
                block_value                : 51,
                block_occupied             : 52,
                block_coords               : 53,
                block_skip_count           : 54,
                debug_variable1            : 55,
                debug_variable2            : 56,
                debug_variable3            : 57,
            }),

            variable1 : folder.add(uniforms, 'variable1').min(-1).max(1).step(0.00000001),
            variable2 : folder.add(uniforms, 'variable2').min(0).max(5).step(0.00000001),
            variable3 : folder.add(uniforms, 'variable3').min(0).max(10).step(1),
            discarding: folder.add(objects, 'FRAGMENT_DISCARDING_DISABLED').name('discarding').onFinishChange((value) => { defines.FRAGMENT_DISCARDING_DISABLED = Number(value), material.needsUpdate = true }),
        }
    }
    
    // controllers bindings

    setBindings()
    {
    
        // raymarch threshold controller
        this.controllers.raymarch.threshold
        .onChange(() => 
        {
            this.displaceColormapLow() // displace colormap low based on raymarch threshold
            this.displaceColormapHigh()  // displace colormap high based on raymarch threshold
        })

        // cap colormap low based on raymarch threshold
        this.controllers.colormap.low.onChange(() => this.capColormapLow())

        // cap colormap high based on raymarch threshold
        this.controllers.colormap.high.onChange(() => this.capColormapHigh())

        // cap raymarch spacing min based on spacing max
        this.controllers.raymarch.steppingMin.onChange(() => this.capRaycastSpacingMin())

        // cap raymarch spacing max based on spacing min
        this.controllers.raymarch.steppingMax.onChange(() => this.capRaycastSpacingMax())
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
        this.controllers.raymarch.steppingMax.setValue
        (
            Math.max
            (
                this.controllers.raymarch.steppingMin.getValue(),
                this.controllers.raymarch.steppingMax.getValue()
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
                this.controllers.raymarch.sampleThreshold.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapHigh()
    {
        this.controllers.colormap.high.setValue
        (
            Math.max
            (
                this.controllers.raymarch.sampleThreshold.getValue(),
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
                this.controllers.raymarch.sampleThreshold.getValue(),
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
                this.controllers.raymarch.sampleThreshold.getValue(), 
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

    dispose() {

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
    
        // Remove any additional debug setups if necessary
        if (this.debug.active) {
            this.viewer.occupancy.dispose()
            this.viewer.occupancy = null
        }
    
        // Clear references
        this.controllers = null
        this.subfolders = null
        this.folders = null
        this.debug = null
        this.viewer = null
    }
    
}
