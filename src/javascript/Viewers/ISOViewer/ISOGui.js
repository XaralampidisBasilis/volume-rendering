
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
        this.subfolders.rendering = this.folders.viewer.addFolder('rendering').close()
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
        this.addControllersRendering() 
        this.addControllersColormap() 
        this.addControllersShading() 
        this.addControllersLighting() 
        this.addControllersDebug() 
        
        // this.setBindings()  
    }

    addControllersRendering() 
    {
        const folder = this.subfolders.rendering
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.u_rendering.value
        const defines = this.viewer.material.defines
        const objects = { 
            min_value                    : 0.0,
            RAY_INTERSECT_BBOX_ENABLED   : Boolean(defines.RAY_INTERSECT_BBOX_ENABLED),
            RAY_INTERSECT_BVOL_ENABLED   : Boolean(defines.RAY_INTERSECT_BVOL_ENABLED),
            RAY_DITHERING_ENABLED        : Boolean(defines.RAY_DITHERING_ENABLED),
            TRACE_SKIPPING_ENABLED       : Boolean(defines.TRACE_SKIPPING_ENABLED),
            TRACE_STEPPING_ENABLED       : Boolean(defines.TRACE_STEPPING_ENABLED),
            TRACE_REFINE_POSITION_ENABLED: Boolean(defines.TRACE_REFINE_POSITION_ENABLED),
            TRACE_REFINE_GRADIENT_ENABLED: Boolean(defines.TRACE_REFINE_GRADIENT_ENABLED),
        }
    

        this.controllers.rendering = 
        {
            minValue           : folder.add(objects, 'min_value').min(0).max(1).step(0.0001).onFinishChange((value) => { uniforms.min_value = value, this.viewer.updateBoundingBox(value),  this.viewer.updateDistmap(value, 4) }),
            minStepScale       : folder.add(uniforms, 'min_step_scaling').min(0.001).max(5).step(0.001),
            maxStepScale       : folder.add(uniforms, 'max_step_scaling').min(0.001).max(5).step(0.001),
            maxStepCount       : folder.add(uniforms, 'max_step_count').min(0).max(1000).step(1),
            maxSkipCount       : folder.add(uniforms, 'max_skip_count').min(0).max(200).step(1),
            enableIntersectBbox: folder.add(objects, 'RAY_INTERSECT_BBOX_ENABLED').name('enable_intersect_bbox').onFinishChange((value) => { defines.RAY_INTERSECT_BBOX_ENABLED = Number(value), material.needsUpdate = true }),
            enableIntersectBvol: folder.add(objects, 'RAY_INTERSECT_BVOL_ENABLED').name('enable_intersect_bvol').onFinishChange((value) => { defines.RAY_INTERSECT_BVOL_ENABLED = Number(value), material.needsUpdate = true }),
            enableDithering    : folder.add(objects, 'RAY_DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.RAY_DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
            enableStepping     : folder.add(objects, 'TRACE_STEPPING_ENABLED').name('enable_stepping').onFinishChange((value) => { defines.TRACE_STEPPING_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping     : folder.add(objects, 'TRACE_SKIPPING_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.TRACE_SKIPPING_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefinePos    : folder.add(objects, 'TRACE_REFINE_POSITION_ENABLED').name('enable_refine_position').onFinishChange((value) => { defines.TRACE_REFINE_POSITION_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefineGrad   : folder.add(objects, 'TRACE_REFINE_GRADIENT_ENABLED').name('enable_refine_gradient').onFinishChange((value) => { defines.TRACE_REFINE_GRADIENT_ENABLED = Number(value), material.needsUpdate = true }),
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
                default                    :  0,
                frag_depth                 :  1,
                ray_step_direction         :  2,
                ray_step_distance          :  3,
                ray_rand_distance          :  4,
                ray_start_distance         :  5,
                ray_end_distance           :  6,
                ray_span_distance          :  7,
                ray_start_position         :  8,
                ray_end_position           :  9,
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
                trace_value                : 20,
                trace_value_error          : 21,
                trace_value_abs_error      : 22,
                trace_normal               : 23,
                trace_gradient             : 24,
                trace_gradient_magnitude   : 25,
                trace_derivative           : 26,
                trace_outside              : 27,
                trace_position             : 28,
                trace_distance             : 29,
                trace_voxel_coords         : 30,
                trace_skip_distance        : 31,
                trace_step_scaling         : 32,
                trace_step_stretching      : 33,
                trace_step_distance        : 34,
                trace_mean_step_scaling    : 35,
                trace_mean_step_distance   : 36,
                trace_spanned_distance     : 37,
                trace_stepped_distance     : 38,
                trace_skipped_distance     : 39,
                trace_step_count           : 40,
                trace_mapped_color         : 41,
                trace_shaded_color         : 42,
                trace_luminance            : 43,
                block_value                : 44,
                block_occupied             : 45,
                block_coords               : 46,
                block_skip_count           : 47,
                debug_variable1            : 48,
                debug_variable2            : 49,
                debug_variable3            : 50,
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
