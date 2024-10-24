
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
        this.subfolders.raycast   = this.folders.viewer.addFolder('raycast').close()
        this.subfolders.gradient  = this.folders.viewer.addFolder('gradient').close()
        this.subfolders.smoothing = this.folders.viewer.addFolder('smoothing').close()
        this.subfolders.colormap  = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.shading   = this.folders.viewer.addFolder('shading').close()
        this.subfolders.lighting  = this.folders.viewer.addFolder('lighting').close()
        this.subfolders.occupancy = this.folders.viewer.addFolder('occupancy').close()

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
        this.addControllersRaycast() 
        this.addControllersGradient() 
        this.addControllersSmoothing() 
        this.addControllersColormap() 
        this.addControllersShading() 
        this.addControllersLighting() 
        this.addControllersOccupancy() 

        if (this.viewer.material.uniforms.u_debug)
            this.addControllersDebug() 

        this.setControllersBindings()  
    }

    addControllersViewer()
    {
        const { viewer } = this.folders

        this.controllers.viewer = 
        {
            visible: viewer.add(this.viewer.mesh, 'visible'),
        }
    }

    addControllersRaycast() 
    {
        const { raycast } = this.subfolders
        const u_raycast = this.viewer.material.uniforms.u_raycast.value
        const defines = this.viewer.material.defines
        const material = this.viewer.material
        const object = { 
            has_refinement: Boolean(defines.HAS_REFINEMENT),
            has_dithering : Boolean(defines.HAS_DITHERING),
            has_skipping  : Boolean(defines.HAS_SKIPPING)
        }

        this.controllers.raycast = 
        {
            threshold: raycast.add(u_raycast, 'threshold').min(0).max(1).step(0.0001)
                .onFinishChange(() => { this.viewer.computeOccupancy() }),

            steppingMin: raycast.add(u_raycast, 'min_stepping').min(0.001).max(5).step(0.001),

            steppingMax: raycast.add(u_raycast, 'max_stepping').min(0.001).max(5).step(0.001),

            maxSteps: raycast.add(u_raycast, 'max_steps').min(0).max(2000).step(1),

            // ditheringScale: raycast.add(u_raycast, 'dithering_scale').min(0).max(1).step(0.001),

            spacingMethod: raycast.add(defines, 'SPACING_METHOD').name('spacing_method')
                .options({ isotropic: 1, directional: 2, equalized: 3 })
                .onFinishChange(() => { material.needsUpdate = true }),
                
            steppingMethod: raycast.add(defines, 'STEPPING_METHOD').name('stepping_method')
                .options({ taylor10: 1, taylor20: 2, taylor30: 3, pade11: 4, pade02: 5, pade21: 6, pade12: 7, pade03: 8, pade22: 9, uniform: 10, })
                .onFinishChange(() => { material.needsUpdate = true }),

            ditheringMethod: raycast.add(defines, 'DITHERING_METHOD').name('dithering_method')
                .options({ generative: 1, texture: 2, })
                .onFinishChange(() => { material.needsUpdate = true }),

            refinementMethod: raycast.add(defines, 'REFINEMENT_METHOD').name('refinement_method')
                .options({ sub_sampling: 1, bisection_iterative: 2, newtons_iterative: 3, linear: 4, lagrange_quadratic: 5, lagrange_cubic: 6, hermite_cubic: 7 })
                .onFinishChange(() => { material.needsUpdate = true }),

            hasRefinement: raycast.add(object, 'has_refinement').onFinishChange((value) => { 
                    defines.HAS_REFINEMENT = Number(value);
                    material.needsUpdate = true 
                }),

            hasDithering: raycast.add(object, 'has_dithering').onFinishChange((value) => { 
                    defines.HAS_DITHERING = Number(value);
                    material.needsUpdate = true 
                }),

            hasSkipping: raycast.add(object, 'has_skipping').onFinishChange((value) => { 
                    defines.HAS_SKIPPING = Number(value);
                    material.needsUpdate = true 
                }),
        }

    }

    addControllersGradient() 
    {
        const { gradient } = this.subfolders
        const u_gradient = this.viewer.material.uniforms.u_gradient.value
        const defines = this.viewer.material.defines
        const object = { has_refinement: false }
    
        this.controllers.gradient = 
        {
            threshold: gradient.add(u_gradient, 'threshold').min(0).max(1).step(0.001),
            
            derivativeMethod: gradient.add(defines, 'DERIVATIVE_METHOD').name('derivative_method')
                .options({hermite30: 1, hermite21: 2, hermite12: 3, hermite22_nopoles: 4, linear: 5, })
                .onFinishChange(() => { this.viewer.material.needsUpdate = true }),

            precomputeMethod: gradient.add(defines, 'GRADIENT_METHOD').name('precompute_method')
                .options({scharr: 1, sobel: 2, prewitt: 3, tetrahedron: 4, central: 5 })
                .onFinishChange(() => { this.viewer.computeGradients() }),

            refinementMethod: gradient.add(defines, 'GRADIENT_REFINEMENT_METHOD').name('refinement_method')
                .options({tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 })
                .onFinishChange(() => { this.viewer.material.needsUpdate = true }),

            hasRefinement: gradient.add(object, 'has_refinement').onFinishChange((value) => 
                { 
                    this.viewer.material.defines.HAS_GRADIENT_REFINEMENT = Number(value);
                    this.viewer.material.needsUpdate = true 
                }),
        }

    }

    addControllersSmoothing()
    {
        const { smoothing } = this.subfolders
        const defines = this.viewer.material.defines
        const object = { has_refinement: false }

        this.controllers.smoothing = 
        {
            radius: smoothing.add(defines, 'SMOOTHING_RADIUS').name('radius').min(0).max(10).step(1)
                .onFinishChange(() => { this.viewer.computeSmoothing() }),
        
            precomputeMethod: smoothing.add(defines, 'SMOOTHING_METHOD').name('precompute_method')
                .options({ bessel: 1, gaussian: 2, average: 3 })
                .onFinishChange(() => { this.viewer.computeSmoothing() }),
        }
    }
    
    addControllersColormap() 
    {
        const { colormap } = this.subfolders
        const u_colormap = this.viewer.material.uniforms.u_colormap.value
        const object = { flip: false }
    
        this.controllers.colormap = 
        {
            low   : colormap.add(u_colormap, 'low').min(0).max(1).step(0.001),
            high  : colormap.add(u_colormap, 'high').min(0).max(1).step(0.001),
            levels: colormap.add(u_colormap, 'levels').min(1).max(255).step(1),
            name  : colormap.add(u_colormap, 'name').options(Object.keys(colormapLocations)),
            flip  : colormap.add(object, 'flip')
        }

    }
    
    addControllersShading() 
    {
        const { shading } = this.subfolders
        const u_shading = this.viewer.material.uniforms.u_shading.value
        const defines = this.viewer.material.defines
    
        this.controllers.shading = 
        {
            reflectanceA   : shading.add(u_shading, 'reflectance_a').min(0).max(1).step(0.001),
            reflectanceD   : shading.add(u_shading, 'reflectance_d').min(0).max(1).step(0.001),
            reflectanceS   : shading.add(u_shading, 'reflectance_s').min(0).max(1).step(0.001),
            shininess      : shading.add(u_shading, 'shininess').min(0).max(40.0).step(0.2),
            shadowThreshold: shading.add(u_shading, 'shadow_threshold').min(0).max(1).step(0.001),
            edgeThreshold  : shading.add(u_shading, 'edge_threshold').min(0).max(1).step(0.001),

            method: shading.add(defines, 'SHADING_METHOD').name('shading_method')
                .options({ blinn : 1, phong : 2})
                .onFinishChange(() => { this.viewer.material.needsUpdate = true }),
        }
    }

    addControllersLighting() 
    {
        const { lighting } = this.subfolders
        const u_lighting = this.viewer.material.uniforms.u_lighting.value
        const defines = this.viewer.material.defines

        this.controllers.lighting = 
        {
            colorA         : lighting.addColor(u_lighting, 'color_a'),
            colorD         : lighting.addColor(u_lighting, 'color_d'),
            colorS         : lighting.addColor(u_lighting, 'color_s'),
            offsetPositionX: lighting.add(u_lighting.offset_position, 'x').min(-5).max(5).step(0.01).name('offset_position_x'),
            offsetPositionY: lighting.add(u_lighting.offset_position, 'y').min(-5).max(5).step(0.01).name('offset_position_y'),
            offsetPositionZ: lighting.add(u_lighting.offset_position, 'z').min(-5).max(5).step(0.01).name('offset_position_z'),
            power          : lighting.add(u_lighting, 'power').min(0).max(2.0).step(0.1),
            
            attenuationMethod: lighting.add(defines, 'ATTENUATION_METHOD').name('attenuation_method')
                .options({ softstep: 1, physical: 2})
                .onFinishChange(() => { this.viewer.material.needsUpdate = true }),

            hasAttenuation: lighting.add(u_lighting, 'has_attenuation'),
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

        // flip colormap colors
        this.controllers.colormap.flip.onChange(() => this.flipColormapRange())

        // locate colormap in texture
        this.controllers.colormap.name.onChange(() => this.locateColormapTexture())

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
                this.controllers.raycast.threshold.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapHigh()
    {
        this.controllers.colormap.high.setValue
        (
            Math.max
            (
                this.controllers.raycast.threshold.getValue(),
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
                this.controllers.raycast.threshold.getValue(),
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
                this.controllers.raycast.threshold.getValue(), 
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    flipColormapRange()
    {
        [this.viewer.material.uniforms.u_colormap.value.texture_columns.y, this.viewer.material.uniforms.u_colormap.value.texture_columns.x] = 
        [this.viewer.material.uniforms.u_colormap.value.texture_columns.x, this.viewer.material.uniforms.u_colormap.value.texture_columns.y]      
    }

    locateColormapTexture()
    {
        let { v, u_start, u_end } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.u_colormap.value.texture_row = v
        this.viewer.material.uniforms.u_colormap.value.texture_columns.set(u_start, u_end)      
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
