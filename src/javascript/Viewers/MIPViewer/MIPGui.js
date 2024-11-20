
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
        this.subfolders.raymarch = this.folders.viewer.addFolder('raymarch').close()
        this.subfolders.volume   = this.folders.viewer.addFolder('volume').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
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
        this.addControllersVolume() 
        this.addControllersColormap() 
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
            RAY_DITHERING_ENABLED            : Boolean(defines.RAY_DITHERING_ENABLED),
            TRACE_BVH_MARCHING_ENABLED       : Boolean(defines.TRACE_BVH_MARCHING_ENABLED),
            TRACE_ADAPTIVE_STEP_ENABLED      : Boolean(defines.TRACE_ADAPTIVE_STEP_ENABLED),
            TRACE_POSITION_REFINEMENT_ENABLED: Boolean(defines.TRACE_POSITION_REFINEMENT_ENABLED),
        }
    

        this.controllers.raymarch = 
        {
            stepSpeed             : folder.add(uniforms, 'step_speed').min(0.001).max(1).step(0.0001),
            minStepScale          : folder.add(uniforms, 'min_step_scaling').min(0.001).max(10).step(0.001),
            maxStepScale          : folder.add(uniforms, 'max_step_scaling').min(0.001).max(10).step(0.001),
            maxStepCount          : folder.add(uniforms, 'max_step_count').min(0).max(2000).step(1),
            enableDithering       : folder.add(objects, 'RAY_DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.RAY_DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
            enableAdaptiveStep    : folder.add(objects, 'TRACE_ADAPTIVE_STEP_ENABLED').name('enable_adaptive_step').onFinishChange((value) => { defines.TRACE_ADAPTIVE_STEP_ENABLED = Number(value), material.needsUpdate = true }),
            enablePosRefinement   : folder.add(objects, 'TRACE_POSITION_REFINEMENT_ENABLED').name('enable_position_refinement').onFinishChange((value) => { defines.TRACE_POSITION_REFINEMENT_ENABLED = Number(value), material.needsUpdate = true }),
        }

    }

    addControllersVolume() 
    {
        const folder = this.subfolders.volume
        const material = this.viewer.material
        const defines = this.viewer.material.defines
        const options = {
            VOLUME_GRADIENTS_METHOD: { scharr: 1, sobel: 2, prewitt: 3, tetrahedron: 4, central: 5 },
            VOLUME_SMOOTHING_METHOD: { bessel: 1, gaussian: 2, average: 3 },
        }

        this.controllers.volume = 
        {
            gradientsMethod: folder.add(defines, 'VOLUME_GRADIENTS_METHOD').name('gradients_method').options(options.VOLUME_GRADIENTS_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            smoothingMethod: folder.add(defines, 'VOLUME_SMOOTHING_METHOD').name('smoothing_method').options(options.VOLUME_SMOOTHING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            smoothingRadius: folder.add(defines, 'VOLUME_SMOOTHING_RADIUS').name('smoothing_radius').min(0).max(5).step(1).onFinishChange(() => { this.viewer.computeSmoothing() }),
            enableVolume   : folder.add(material, 'visible').name('enable_volume')
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
                default                     : 0,
                frag_depth                  : 1,
                ray_camera_position         : 2,
                ray_camera_direction        : 3,
                ray_step_direction          : 4,
                ray_step_distance           : 5,
                ray_rand_distance           : 6,
                ray_start_distance          : 7,
                ray_end_distance            : 8,
                ray_span_distance           : 9,
                ray_start_position          : 10,
                ray_end_position            : 11,
                ray_max_step_count          : 12,
                ray_min_start_distance      : 13,
                ray_max_end_distance        : 14,
                ray_max_span_distance       : 15,
                trace_terminated            : 16,
                trace_suspended             : 17,
                trace_distance              : 18,
                trace_position              : 19,
                trace_voxel_coords          : 20,
                trace_step_count            : 21,
                trace_step_distance         : 22,
                trace_step_scaling          : 23,
                trace_mean_step_scaling     : 24,
                trace_mean_step_distance    : 25,
                max_trace_distance          : 26,
                max_trace_position          : 27,
                max_trace_voxel_coords      : 28,
                max_trace_step_count        : 29,
                max_trace_step_distance     : 30,
                max_trace_step_scaling      : 31,
                max_trace_sample_value      : 32,
                max_trace_mapped_color      : 33,
                max_trace_gradient          : 34,
                max_trace_gradient_magnitude: 35,
                max_trace_gradient_direction: 36,
                max_trace_derivative        : 37,
                debug_variable1             : 38,
                debug_variable2             : 39,
                debug_variable3             : 40,
            }),

            variable1 : folder.add(uniforms, 'variable1').min(-1).max(1).step(0.00000001),
            variable2 : folder.add(uniforms, 'variable2').min(-10).max(10).step(0.00000001),
            variable3 : folder.add(uniforms, 'variable3').min(0).max(50).step(1),
            variable4 : folder.add(uniforms, 'variable4').min(1).max(5).step(1),
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
