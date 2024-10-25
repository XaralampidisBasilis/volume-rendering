
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
        this.subfolders           = {}
        this.subfolders.raymarch  = this.folders.viewer.addFolder('raymarch').close()
        this.subfolders.volume    = this.folders.viewer.addFolder('volume').close()
        this.subfolders.colormap  = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.shading   = this.folders.viewer.addFolder('shading').close()
        this.subfolders.lighting  = this.folders.viewer.addFolder('lighting').close()

        if (this.viewer.material.uniforms.u_debug)
            this.subfolders.debug = this.folders.viewer.addFolder('debug').close()


        this.addSubfolderToggles()            
    }

    addSubfolderToggles()
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
        this.addControllersViewer()
        this.addControllersRaymarch() 
        this.addControllersVolume() 
        this.addControllersColormap() 
        this.addControllersShading() 
        this.addControllersLighting() 
        this.addControllersDebug() 

        // this.setControllersBindings()  
    }

    addControllersViewer()
    {
        const { viewer } = this.folders

        this.controllers.viewer = 
        {
            visible: viewer.add(this.viewer.mesh, 'visible'),
        }
    }

    addControllersRaymarch() 
    {
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.raymarch.value
        const defines = this.viewer.material.defines
        const objects = { 
            RAYMARCH_DITHERING_ENABLED : Boolean(defines.RAYMARCH_DITHERING_ENABLED),
            RAYMARCH_REFINEMENT_ENABLED: Boolean(defines.RAYMARCH_REFINEMENT_ENABLED),
            RAYMARCH_SKIPPING_ENABLED  : Boolean(defines.RAYMARCH_SKIPPING_ENABLED),
            RAYMARCH_GRADIENTS_ENABLED : Boolean(defines.RAYMARCH_GRADIENTS_ENABLED),
            RAYMARCH_SMOOTHING_ENABLED : Boolean(defines.RAYMARCH_SMOOTHING_ENABLED),
        }
        const options = {
            RAYMARCH_DITHERING_METHOD  : { generative: 1, texture: 2, },
            RAYMARCH_STEPPING_METHOD   : { isotropic: 1, directional: 2, equalized: 3 },
            RAYMARCH_SCALING_METHOD    : { taylor10: 1, taylor20: 2, taylor30: 3, pade11: 4, pade02: 5, pade21: 6, pade12: 7, pade03: 8, pade22: 9, uniform: 10, },
            RAYMARCH_REFINEMENT_METHOD : { sub_sampling: 1, bisection_iterative: 2, newtons_iterative: 3, linear: 4, lagrange_quadratic: 5, lagrange_cubic: 6, hermite_cubic: 7 },
            RAYMARCH_DERIVATIVES_METHOD: { hermite30: 1, hermite21: 2, hermite12: 3, hermite22_nopoles: 4, linear: 5, },
            RAYMARCH_GRADIENTS_METHOD  : { tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 },
            RAYMARCH_SMOOTHING_METHOD  : { bessel: 1, gaussian: 2, average: 3 },
        }

        const controls = this.subfolders.raycast.addFolder('raymarch').close()
        const methods  = this.subfolders.raycast.addFolder('raymarch').close()
        const enablers = this.subfolders.raycast.addFolder('raymarch').close()

        this.controllers.raycast = 
        {
            sampleThreshold   : controls.add(uniforms, 'sample_threshold').min(0).max(1).step(0.0001).onFinishChange(() => { this.viewer.computeOccupancy() }),
            gradientThreshold : controls.add(uniforms, 'gradient_threshold').min(0).max(1).step(0.0001),
            minStepScale      : controls.add(uniforms, 'min_step_scale').min(0.001).max(5).step(0.001),
            maxStepScale      : controls.add(uniforms, 'max_step_scale').min(0.001).max(5).step(0.001),
            maxStepCount      : controls.add(uniforms, 'max_step_count').min(0).max(2000).step(1),
            maxSkipCount      : controls.add(uniforms, 'max_skip_count').min(0).max(100).step(1),
            minSkipLod        : controls.add(uniforms, 'min_skip_lod').min(0).max(10).step(1),

            spacingMethod     : methods.add(defines, 'RAYMARCH_STEPPING_METHOD').name('stepping_method').options(options.RAYMARCH_STEPPING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            scalingMethod     : methods.add(defines, 'RAYMARCH_SCALING_METHOD').name('stepping_method').options(options.RAYMARCH_SCALING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            ditheringMethod   : methods.add(defines, 'RAYMARCH_DITHERING_METHOD').name('dithering_method').options(options.RAYMARCH_DITHERING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            refinementMethod  : methods.add(defines, 'RAYMARCH_REFINEMENT_METHOD').name('refinement_method').options(options.RAYMARCH_REFINEMENT_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            derivativeMethod  : methods.add(defines, 'RAYMARCH_DERIVATIVES_METHOD').name('derivatives_method').options(options.RAYMARCH_DERIVATIVES_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            gradientsMethod   : methods.add(defines, 'RAYMARCH_GRADIENTS_METHOD').name('refinement_method').options(options.RAYMARCH_GRADIENTS_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            smoothingMethod   : methods.add(defines, 'RAYMARCH_SMOOTHING_METHOD').name('refinement_method').options(options.RAYMARCH_SMOOTHING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            
            enableDithering   : enablers.add(objects, 'RAYMARCH_DITHERING_ENABLED').name('enable_dithering').onFinishChange((value) => { defines.RAYMARCH_DITHERING_ENABLED = Number(value), material.needsUpdate = true }),
            enableRefinement  : enablers.add(objects, 'RAYMARCH_REFINEMENT_ENABLED').name('enable_refinement').onFinishChange((value) => { defines.RAYMARCH_REFINEMENT_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping    : enablers.add(objects, 'RAYMARCH_SKIPPING_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.RAYMARCH_SKIPPING_ENABLED = Number(value), material.needsUpdate = true }),
            enableGradients   : enablers.add(objects, 'RAYMARCH_GRADIENTS_ENABLED').name('enable_gradients').onFinishChange((value) => { defines.RAYMARCH_GRADIENTS_ENABLED = Number(value), material.needsUpdate = true }),
            enableSmoothing   : enablers.add(objects, 'RAYMARCH_SMOOTHING_ENABLED').name('enable_smoothing').onFinishChange((value) => { defines.RAYMARCH_SMOOTHING_ENABLED = Number(value), material.needsUpdate = true }),
        }

    }

    addControllersVolume() 
    {
        const material = this.viewer.material
        const uniforms = this.viewer.material.uniforms.volume.value
        const defines = this.viewer.material.defines
        const objects = { 
            VOLUME_BOUNDING_BOX_ENABLED: Boolean(defines.VOLUME_BOUNDING_BOX_ENABLED),
            VOLUME_SKIPPING_ENABLED    : Boolean(defines.VOLUME_SKIPPING_ENABLED),
        }
        const options = {
            VOLUME_GRADIENTS_METHOD: { scharr: 1, sobel: 2, prewitt: 3, tetrahedron: 4, central: 5 },
            VOLUME_SMOOTHING_METHOD: { bessel: 1, gaussian: 2, average: 3 },
        }

        const folder = this.subfolders.volume

        this.controllers.volume = 
        {
            smoothingRadius: folder.add(defines, 'VOLUME_SMOOTHING_RADIUS').name('smoothing_radius').min(0).max(5).step(1).onFinishChange(() => { this.viewer.computeSmoothing() }),
            smoothingMethod: folder.add(defines, 'VOLUME_SMOOTHING_METHOD').name('smoothing_method').options(options.VOLUME_SMOOTHING_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            gradientsMethod: folder.add(defines, 'VOLUME_GRADIENTS_METHOD').name('gradients_method').options(options.VOLUME_GRADIENTS_METHOD).onFinishChange(() => { material.needsUpdate = true }),
            enableBbox     : folder.add(objects, 'VOLUME_BOUNDING_BOX_ENABLED').name('enable_bbox').onFinishChange((value) => { defines.VOLUME_BOUNDING_BOX_ENABLED = Number(value), material.needsUpdate = true }),
            enableSkipping : folder.add(objects, 'VOLUME_SKIPPING_ENABLED').name('enable_skipping').onFinishChange((value) => { defines.VOLUME_SKIPPING_ENABLED = Number(value), material.needsUpdate = true }),
        }

    }

    addControllersColormap() 
    {
        const folder = this.subfolders.colormap
        const uniforms = this.viewer.material.uniforms.colormap.value
        const object = { flip: false }
    
        this.controllers.colormap = 
        {
            name        : folder.add(uniforms, 'name').options(Object.keys(colormapLocations)).onChange(this.updateColormap),
            minThreshold: folder.add(uniforms.thresholds, 'x').name('min_threshold').min(0).max(1).step(0.001),
            maxThreshold: folder.add(uniforms.thresholds, 'y').name('max_threshold').min(0).max(1).step(0.001),
            levels      : folder.add(uniforms, 'levels').min(1).max(255).step(1),
            flip        : folder.add(object, 'flip').onChange(this.flipColormap)
        }

    }
    
    addControllersShading() 
    {
        const folder = this.subfolders.shading
        const uniforms = this.viewer.material.uniforms.shading.value
        const defines = this.viewer.material.defines
        const options = { SHADING_METHOD: { blinn : 1, phong : 2} }

        this.controllers.shading = 
        {
            ambientReflectance : folder.add(uniforms, 'ambient_reflectance').min(0).max(1).step(0.001),
            diffuseReflectance : folder.add(uniforms, 'diffuse_reflectance').min(0).max(1).step(0.001),
            specularReflectance: folder.add(uniforms, 'specular_reflectance').min(0).max(1).step(0.001),
            shininess          : folder.add(uniforms, 'shininess').min(0).max(40.0).step(0.2),
            edgeContrast       : folder.add(uniforms, 'shadow_threshold').min(0).max(1).step(0.001),
            shadingMethod      : folder.add(defines, 'SHADING_METHOD').name('shading_method').options(options.SHADING_METHOD).onFinishChange(() => { this.viewer.material.needsUpdate = true }),
        }
    }

    addControllersLighting() 
    {
        const folder = this.subfolders.lighting
        const uniforms = this.viewer.material.uniforms.u_lighting.value
        const defines = this.viewer.material.defines

        this.controllers.lighting = 
        {
            intensity     : folder.add(uniforms, 'intensity').min(0).max(2.0).step(0.001),
            shadows       : folder.add(uniforms, 'shadows').min(0).max(1.0).step(0.001),
            ambient_color : folder.addColor(uniforms, 'ambient_color'),
            diffuse_color : folder.addColor(uniforms, 'diffuse_color'),
            specular_color: folder.addColor(uniforms, 'specular_color'),


            offsetPositionX: folder.add(uniforms.offset_position, 'x').min(-5).max(5).step(0.01).name('offset_position_x'),
            offsetPositionY: folder.add(uniforms.offset_position, 'y').min(-5).max(5).step(0.01).name('offset_position_y'),
            offsetPositionZ: folder.add(uniforms.offset_position, 'z').min(-5).max(5).step(0.01).name('offset_position_z'),
            
            attenuationMethod: folder.add(defines, 'ATTENUATION_METHOD').name('attenuation_method')
                .options({ softstep: 1, physical: 2})
                .onFinishChange(() => { this.viewer.material.needsUpdate = true }),

            hasAttenuation: folder.add(uniforms, 'has_attenuation'),
        }
    }
    
    addControllersOccupancy() 
    {
        const { occupancy } = this.subfolders
        const u_occupancy = this.viewer.material.uniforms.u_occupancy.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const object = { 
            has_bbox: Boolean(defines.HAS_OCCUPANCY_BBOX),
            has_maps: Boolean(defines.HAS_OCCUPANCY_MAPS),
        }

        this.controllers.occupancy = 
        {
            maxSkips : occupancy.add(u_occupancy, 'max_skips').min(0).max(1000).step(1),

            minLod : occupancy.add(u_occupancy, 'min_lod').min(0).max(10).step(1),

            hasBbox: occupancy.add(object, 'has_bbox').onFinishChange((value) => { 
                    defines.HAS_OCCUPANCY_BBOX = Number(value);
                    material.needsUpdate = true 
                }),

            hasMaps: occupancy.add(object, 'has_maps').onFinishChange((value) => { 
                    defines.HAS_OCCUPANCY_MAPS = Number(value);
                    material.needsUpdate = true 
                }),
        }

        

    }

    addControllersDebug()
    {
        const { debug } = this.subfolders
        const u_debug = this.viewer.material.uniforms.u_debug.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const object = { 
            full: Boolean(defines.HAS_DEBUG_FULL),
        }

        this.controllers.debug = 
        {
            option: debug.add(u_debug, 'option').options({ 
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

            full: debug.add(object, 'full').onFinishChange((value) => { 
                    defines.HAS_DEBUG_FULL = Number(value);
                    material.needsUpdate = true 
                }),

            number   : debug.add(u_debug, 'number').min(0).max(1000).step(1),
            scale    : debug.add(u_debug, 'scale').min(0).max(100).step(0.001),
            constant : debug.add(u_debug, 'constant').min(0).max(10).step(0.000001),
            mixing   : debug.add(u_debug, 'mixing').min(0).max(1).step(0.000001),
            epsilon  : debug.add(u_debug, 'epsilon').min(-2).max(2).step(0.0000001),
            tolerance: debug.add(u_debug, 'tolerance').min(-1).max(1).step(1e-30),
            texel    : debug.addColor(u_debug, 'texel'),
        }
    }
    
    // controllers bindings

    setControllersBindings()
    {
    
        // raycast threshold controller
        this.controllers.raycast.threshold
        .onChange(() => 
        {
            this.displaceColormapLow() // displace colormap low based on raycast threshold
            this.displaceColormapHigh()  // displace colormap high based on raycast threshold
        })

        // cap colormap low based on raycast threshold
        this.controllers.colormap.low.onChange(() => this.capColormapLow())

        // cap colormap high based on raycast threshold
        this.controllers.colormap.high.onChange(() => this.capColormapHigh())

        // cap raycast spacing min based on spacing max
        this.controllers.raycast.steppingMin.onChange(() => this.capRaycastSpacingMin())

        // cap raycast spacing max based on spacing min
        this.controllers.raycast.steppingMax.onChange(() => this.capRaycastSpacingMax())
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
        this.controllers.raycast.steppingMax.setValue
        (
            Math.max
            (
                this.controllers.raycast.steppingMin.getValue(),
                this.controllers.raycast.steppingMax.getValue()
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
                this.controllers.raycast.sampleThreshold.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapHigh()
    {
        this.controllers.colormap.high.setValue
        (
            Math.max
            (
                this.controllers.raycast.sampleThreshold.getValue(),
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
                this.controllers.raycast.sampleThreshold.getValue(),
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
                this.controllers.raycast.sampleThreshold.getValue(), 
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
