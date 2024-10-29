
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
        this.subfolders.volume   = this.folders.viewer.addFolder('volume').close()
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
        this.addControllersVolume() 
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
        const uniforms = this.viewer.material.uniforms.raymarch.value
        const defines = this.viewer.material.defines
        const objects = { 
            RAY_DITHERING_ENABLED  : Boolean(defines.RAY_DITHERING_ENABLED),
            RAY_REFINEMENT_ENABLED : Boolean(defines.RAY_REFINEMENT_ENABLED),
            TRACE_SKIP_OMAP_ENABLED: Boolean(defines.TRACE_SKIP_OMAP_ENABLED),
            RAY_GRADIENTS_ENABLED  : Boolean(defines.RAY_GRADIENTS_ENABLED),
            RAY_SMOOTHING_ENABLED  : Boolean(defines.RAY_SMOOTHING_ENABLED),
        }
        const options = {
            RAY_DITHERING_METHOD    : { generative: 1, texture: 2, },
            RAY_STEPPING_METHOD     : { isotropic: 1, directional: 2, equalized: 3 },
            TRACE_SCALING_METHOD    : { taylor10: 1, taylor20: 2, taylor30: 3, pade11: 4, pade02: 5, pade21: 6, pade12: 7, pade03: 8, pade22: 9, uniform: 10, },
            RAY_REFINEMENT_METHOD   : { sub_sampling: 1, bisection_iterative: 2, newtons_iterative: 3, linear: 4, lagrange_quadratic: 5, lagrange_cubic: 6, hermite_cubic: 7 },
            TRACE_DERIVATIVES_METHOD: { hermite30: 1, hermite21: 2, hermite12: 3, hermite22_nopoles: 4, linear: 5, },
            RAY_GRADIENTS_METHOD    : { tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 },
            RAY_SMOOTHING_METHOD    : { bessel: 1, gaussian: 2, average: 3 },
        }

        // const controls = this.subfolders.raymarch.addFolder('controls').close()
        // const methods  = this.subfolders.raymarch.addFolder('methods').close()
        // const enablers = this.subfolders.raymarch.addFolder('enablers').close()

        this.controllers.raymarch = 
        {
            sampleThreshold   : folder.add(uniforms, 'sample_threshold').min(0).max(1).step(0.0001).onFinishChange(() => { this.viewer.computeOccupancy() }),
            gradientThreshold : folder.add(uniforms, 'gradient_threshold').min(0).max(1).step(0.0001),
            minStepScale      : folder.add(uniforms, 'min_step_scale').min(0.001).max(5).step(0.001),
            maxStepScale      : folder.add(uniforms, 'max_step_scale').min(0.001).max(5).step(0.001),
            maxStepCount      : folder.add(uniforms, 'max_step_count').min(0).max(2000).step(1),
            maxSkipCount      : folder.add(uniforms, 'max_skip_count').min(0).max(100).step(1),
            skipLod           : folder.add(uniforms, 'skip_lod').min(0).max(10).step(1),

            spacingMethod     : folder.add(defines, 'RAY_STEPPING_METHOD').name('stepping_method').options(options.RAY_STEPPING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            scalingMethod     : folder.add(defines, 'TRACE_SCALING_METHOD').name('scaling_method').options(options.TRACE_SCALING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            ditheringMethod   : folder.add(defines, 'RAY_DITHERING_METHOD').name('dithering_method').options(options.RAY_DITHERING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            refinementMethod  : folder.add(defines, 'RAY_REFINEMENT_METHOD').name('refinement_method').options(options.RAY_REFINEMENT_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            derivativeMethod  : folder.add(defines, 'TRACE_DERIVATIVES_METHOD').name('derivatives_method').options(options.TRACE_DERIVATIVES_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            gradientsMethod   : folder.add(defines, 'RAY_GRADIENTS_METHOD').name('gradients_method').options(options.RAY_GRADIENTS_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            smoothingMethod   : folder.add(defines, 'RAY_SMOOTHING_METHOD').name('smoothing_method').options(options.RAY_SMOOTHING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            
            enableDithering   : folder.add(objects, 'RAY_DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.RAY_DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefinement  : folder.add(objects, 'RAY_REFINEMENT_ENABLED').name('enable_refinement').onFinishChange((value) => { defines.RAY_REFINEMENT_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping    : folder.add(objects, 'TRACE_SKIP_OMAP_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.TRACE_SKIP_OMAP_ENABLED = Number(value), material.needsUpdate = true }),
            enableGradients   : folder.add(objects, 'RAY_GRADIENTS_ENABLED').name('enable_gradients').onFinishChange((value) => { defines.RAY_GRADIENTS_ENABLED = Number(value), material.needsUpdate = true }),
            enableSmoothing   : folder.add(objects, 'RAY_SMOOTHING_ENABLED').name('enable_smoothing').onFinishChange((value) => { defines.RAY_SMOOTHING_ENABLED = Number(value), material.needsUpdate = true }),
        }

    }

    addControllersVolume() 
    {
        const folder = this.subfolders.volume
        const material = this.viewer.material
        const defines = this.viewer.material.defines
        const objects = { 
            VOLUME_SKIP_BBOX_ENABLED: Boolean(defines.VOLUME_SKIP_BBOX_ENABLED),
            VOLUME_SKIP_OMAPS_ENABLED    : Boolean(defines.VOLUME_SKIP_OMAPS_ENABLED),
        }
        const options = {
            VOLUME_GRADIENTS_METHOD: { scharr: 1, sobel: 2, prewitt: 3, tetrahedron: 4, central: 5 },
            VOLUME_SMOOTHING_METHOD: { bessel: 1, gaussian: 2, average: 3 },
        }

        this.controllers.volume = 
        {
            smoothingRadius: folder.add(defines, 'VOLUME_SMOOTHING_RADIUS').name('smoothing_radius').min(0).max(5).step(1).onFinishChange(() => { this.viewer.computeSmoothing() }),
            smoothingMethod: folder.add(defines, 'VOLUME_SMOOTHING_METHOD').name('smoothing_method').options(options.VOLUME_SMOOTHING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            gradientsMethod: folder.add(defines, 'VOLUME_GRADIENTS_METHOD').name('gradients_method').options(options.VOLUME_GRADIENTS_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            enableSkipBbox : folder.add(objects, 'VOLUME_SKIP_BBOX_ENABLED').name('enable_bbox').onFinishChange((value) => { defines.VOLUME_SKIP_BBOX_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipOmaps: folder.add(objects, 'VOLUME_SKIP_OMAPS_ENABLED').name('enable_omaps').onFinishChange((value) => { defines.VOLUME_SKIP_OMAPS_ENABLED = Number(value), material.needsUpdate = true }),
            enableVolume   : folder.add(material, 'visible').name('enable_volume')
        }

    }

    addControllersColormap() 
    {
        const folder = this.subfolders.colormap
        const uniforms = this.viewer.material.uniforms.colormap.value
        const objects = { flip: false }
    
        this.controllers.colormap = 
        {
            name        : folder.add(uniforms, 'name').options(Object.keys(colormapLocations)).onChange(this.updateColormap),
            minThreshold: folder.add(uniforms.thresholds, 'x').name('min_threshold').min(0).max(1).step(0.001),
            maxThreshold: folder.add(uniforms.thresholds, 'y').name('max_threshold').min(0).max(1).step(0.001),
            levels      : folder.add(uniforms, 'levels').min(1).max(255).step(1),
            flip        : folder.add(objects, 'flip').onChange(this.flipColormap)
        }

    }
    
    addControllersShading() 
    {
        const folder = this.subfolders.shading
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.shading.value
        const defines = this.viewer.material.defines
        const options = { SHADING_METHOD: { blinn : 1, phong : 2} }

        this.controllers.shading = 
        {
            ambientReflectance : folder.add(uniforms, 'ambient_reflectance').min(0).max(1).step(0.001),
            diffuseReflectance : folder.add(uniforms, 'diffuse_reflectance').min(0).max(1).step(0.001),
            specularReflectance: folder.add(uniforms, 'specular_reflectance').min(0).max(1).step(0.001),
            shininess          : folder.add(uniforms, 'shininess').min(0).max(40.0).step(0.2),
            edgeContrast       : folder.add(uniforms, 'edge_contrast').min(0).max(1).step(0.001),
            shadingMethod      : folder.add(defines, 'SHADING_METHOD').name('shading_method').options(options.SHADING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
        }
    }

    addControllersLighting() 
    {
        const folder = this.subfolders.lighting
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.lighting.value
        const defines = this.viewer.material.defines
        const objects = { LIGHTING_ATTENUATION_ENABLED: Boolean(defines.LIGHTING_ATTENUATION_ENABLED) }
        const options = { LIGHTING_ATTENUATION_METHOD: { softstep: 1, physical: 2} }

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
            attenuationMethod: folder.add(defines, 'LIGHTING_ATTENUATION_METHOD').name('attenuation_method').options(options.LIGHTING_ATTENUATION_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            enableAttenuation: folder.add(objects, 'LIGHTING_ATTENUATION_ENABLED').name('enable_attenuation').onFinishChange((value) => { defines.LIGHTING_ATTENUATION_ENABLED = Number(value), material.needsUpdate = true }),
        }
    }
    
    addControllersDebug()
    {
        const folder = this.subfolders.debug
        const uniforms = this.viewer.material.uniforms.raymarch.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const objects = { DEBUG_DISCARDING_ENABLED: Boolean(defines.DEBUG_DISCARDING_ENABLED) }

        this.controllers.debug = 
        {
            option: folder.add(uniforms, 'debug_option').options({ 
                default            :  0,
                trace_position     :  1,
                trace_coords       :  2,
                trace_distance     :  3,
                trace_depth        :  4,
                trace_outside      :  5,
                trace_traversed    :  6,
                trace_skipped      :  7,
                trace_steps        :  8,
                trace_error        :  9,
                trace_abs_error    : 10,
                trace_value        : 11,
                trace_color        : 12,
                trace_shading      : 13,
                trace_luminance    : 14,
                trace_normal       : 15,
                trace_gradient     : 16,
                trace_gradient_norm: 17,
                trace_derivative   : 18,
                trace_derivative2  : 19,
                trace_derivative3  : 20,
                trace_stepping     : 21,
                trace_mean_stepping: 22,
                ray_direction      : 23,
                ray_spacing        : 24,
                ray_dithering      : 25,
                ray_min_distance   : 26,
                ray_max_distance   : 27,
                ray_max_depth      : 28,
                ray_max_steps      : 29,
                block_lod          : 30,
                block_coords       : 31,
                block_max_position : 32,
                block_min_position : 33,
                block_occupied     : 34,
                block_skipping     : 35,
                block_skips        : 36,
                frag_depth         : 37,
                variable1          : 38,
                variable2          : 39,
                variable3          : 40,
            }),

            enable_discarding: folder.add(objects, 'DEBUG_DISCARDING_ENABLED').name('enable_discarding').onFinishChange((value) => { defines.DEBUG_DISCARDING_ENABLED = Number(value), material.needsUpdate = true }),
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
        const colormap = this.viewer.material.uniforms.colormap.value
        [colormap.start_coords.x, colormap.end_coords.x] = 
        [colormap.end_coords.x, colormap.start_coords.x]      
    }

    updateColormap()
    {
        let { x_start, x_end, y } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.colormap.value.start_coords.set(x_start, y)
        this.viewer.material.uniforms.colormap.value.end_coords.set(x_end, y)      
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
