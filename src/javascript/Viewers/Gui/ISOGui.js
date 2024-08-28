
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
        this.subfolders = {}
        this.subfolders.raycast = this.folders.viewer.addFolder('raycast').close()
        this.subfolders.gradient = this.folders.viewer.addFolder('gradient').close()
        this.subfolders.colormap = this.folders.viewer.addFolder('colormap').close()
        this.subfolders.lighting = this.folders.viewer.addFolder('lighting').close()
        this.subfolders.occupancy = this.folders.viewer.addFolder('occupancy').close()   
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
        this.addControllersColormap() 
        this.addControllersLighting() 

        if (this.viewer.occupancy)
            this.addControllersOccupancy() 

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

        this.controllers.raycast = 
        {
            threshold: raycast.add(u_raycast, 'threshold').min(0).max(1).step(0.0001),
            spacingMin: raycast.add(u_raycast, 'spacing_min').min(0.01).max(3).step(0.001),
            spacingMax: raycast.add(u_raycast, 'spacing_max').min(0.01).max(3).step(0.001),
            refinements: raycast.add(u_raycast, 'refinements').min(0).max(5).step(1),
            step_method: raycast.add(u_raycast, 'step_method').options({ isotropic: 1, directional: 2, traversal: 3 }),
            dither_method: raycast.add(u_raycast, 'dither_method').options({ generative: 1, texture: 2, }),
            dithering: raycast.add(u_raycast, 'dithering'),
            skipping: raycast.add(u_raycast, 'skipping')
        }

    }

    addControllersGradient() 
    {
        const { gradient } = this.subfolders
        const u_gradient = this.viewer.material.uniforms.u_gradient.value
    
        this.controllers.gradient = 
        {
            threshold: gradient.add(u_gradient, 'threshold').min(0).max(1).step(0.001),
            resolution: gradient.add(u_gradient, 'resolution').min(0).max(1).step(0.001),
            method: gradient.add(u_gradient, 'method').options({ sobel: 1, central: 2, tetrahedron: 3}),
            max_sampling: gradient.add(u_gradient, 'max_sampling')
        }

    }
    
    addControllersColormap() 
    {
        const { colormap } = this.subfolders
        const u_colormap = this.viewer.material.uniforms.u_colormap.value
        const object = { flip: false }
    
        this.controllers.colormap = 
        {
            low: colormap.add(u_colormap, 'low').min(0).max(1).step(0.001),
            high: colormap.add(u_colormap, 'high').min(0).max(1).step(0.001),
            levels: colormap.add(u_colormap, 'levels').min(1).max(255).step(1),
            name: colormap.add(u_colormap, 'name').options(Object.keys(colormapLocations)),
            flip: colormap.add(object, 'flip')
        }

    }
    
    addControllersLighting() 
    {
        const { lighting } = this.subfolders
        const u_lighting = this.viewer.material.uniforms.u_lighting.value
    
        this.controllers.lighting = 
        {
            ka: lighting.add(u_lighting, 'ka').min(0).max(10).step(0.001),
            kd: lighting.add(u_lighting, 'kd').min(0).max(1).step(0.001),
            ks: lighting.add(u_lighting, 'ks').min(0).max(1).step(0.001),
            shadows: lighting.add(u_lighting, 'shadows').min(0).max(1.0).step(0.01),
            shininess: lighting.add(u_lighting, 'shininess').min(0).max(40.0).step(0.2),
            edge_threshold: lighting.add(u_lighting, 'edge_threshold').min(0).max(1).step(0.001),
            power: lighting.add(u_lighting, 'power').min(0).max(2.0).step(0.1),
            position_x: lighting.add(u_lighting.position, 'x').min(-2).max(2).step(0.01).name('position_x'),
            position_y: lighting.add(u_lighting.position, 'y').min(-2).max(2).step(0.01).name('position_y'),
            position_z: lighting.add(u_lighting.position, 'z').min(-2).max(2).step(0.01).name('position_z'),
            model: lighting.add(u_lighting, 'model').options({ phong: 1, blinn: 2}),
            attenuation: lighting.add(u_lighting, 'attenuation'),
        }
    }
    
    addControllersOccupancy() 
    {
        const { occupancy } = this.subfolders
        const u_occupancy = this.viewer.material.uniforms.u_occupancy.value
        const object = { options: 0 }

        this.controllers.occupancy = 
        {
            divisions: occupancy.add(u_occupancy, 'divisions').min(2).max(20).step(1),
            occubox: occupancy.add(this.viewer.occupancy.helpers.occubox, 'visible').name('occubox'),
            computation: occupancy.add(this.viewer.occupancy.helpers.computation, 'visible').name('computation'),
            occumaps: occupancy.add(this.viewer.occupancy.helpers.occumaps, 'visible').name('occumaps'),
            levels: occupancy.add(object, 'options').options({ all: 0, level0: 1, level1: 2, level2: 3}).name('levels'),
        }

    }
    
    // controllers bindings

    setControllersBindings()
    {
    
        // raycast threshold controller
        this.controllers.raycast.threshold
        .onChange(() => 
        {
            // displace colormap low based on raycast threshold
            this.displaceColormapLow()

            // displace colormap high based on raycast threshold
            this.displaceColormapHigh()
        })
        .onFinishChange(() => 
        {
            if (this.viewer.occupancy)
                this.viewer.occupancy.compute()
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
        this.controllers.raycast.spacingMin.onChange(() => this.capRaycastSpacingMin())

        // cap raycast spacing max based on spacing min
        this.controllers.raycast.spacingMax.onChange(() => this.capRaycastSpacingMax())
    
        // adjust lighting power based on lighting attenuations being on or off
        // this.controllers.lighting.attenuation.onChange(() => this.adjustLightingPower())

        if (this.viewer.occupancy)
        {
            this.controllers.occupancy.levels.onChange(() => this.occumapsVisible())

            // recompute new occupancy based on new divisions
            this.controllers.occupancy.divisions.onFinishChange(() => this.changeOccupancyDivisions())
        }
    }

    capRaycastSpacingMin()
    {
        this.controllers.raycast.spacingMin.setValue
        (
            Math.min
            (
                this.controllers.raycast.spacingMin.getValue(),
                this.controllers.raycast.spacingMax.getValue()
            )
        ).updateDisplay()
    }

    capRaycastSpacingMax()
    {
        this.controllers.raycast.spacingMax.setValue
        (
            Math.max
            (
                this.controllers.raycast.spacingMin.getValue(),
                this.controllers.raycast.spacingMax.getValue()
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
        [this.viewer.material.uniforms.u_colormap.value.texture_range.y, this.viewer.material.uniforms.u_colormap.value.texture_range.x] = 
        [this.viewer.material.uniforms.u_colormap.value.texture_range.x, this.viewer.material.uniforms.u_colormap.value.texture_range.y]      
    }

    locateColormapTexture()
    {
        let { v, u_start, u_end } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.u_colormap.value.texture_id = v
        this.viewer.material.uniforms.u_colormap.value.texture_range.set(u_start, u_end)      
    }

    adjustLightingPower()
    {
        if (this.controllers.lighting.attenuation.getValue())

            this.controllers.lighting.power
                .min(0)
                .max(20)
                .setValue(7)
                .updateDisplay()
        else
                this.controllers.lighting.power
                .min(0)
                .max(2)
                .setValue(1)
                .updateDisplay()
    }

    occumapsVisible()
    {
        const option = this.controllers.occupancy.levels.getValue()

        switch (option)
        {
            case 0:
                this.viewer.occupancy.helpers.occumaps.children.forEach((child) => child.material.visible = true)
                break;
            case 1:
                this.viewer.occupancy.helpers.occumaps.children.forEach((child, i) => child.material.visible = (i === 0))
                break;
            case 2:
                this.viewer.occupancy.helpers.occumaps.children.forEach((child, i) => child.material.visible = (i === 1))
                break;
            case 3:
                this.viewer.occupancy.helpers.occumaps.children.forEach((child, i) => child.material.visible = (i === 2))
                break;
            default:
                break;
        }
    }

    changeOccupancyDivisions()
    {
        const occuboxVisible = this.controllers.occupancy.occubox.getValue()
        const occumapsVisible = this.controllers.occupancy.occumaps.getValue()
        const computationVisible = this.controllers.occupancy.computation.getValue()

        this.viewer.occupancy.dispose()
        this.viewer.computeOccupancy()

        // destroy and create occupancy visible controller
        this.controllers.occupancy.occubox.destroy()
        this.controllers.occupancy.occumaps.destroy()
        this.controllers.occupancy.computation.destroy()
        
        this.controllers.occupancy.occubox = this.subfolders.occupancy.add(this.viewer.occupancy.helpers.occubox, 'visible').name('occubox').setValue(occuboxVisible).updateDisplay()
        this.controllers.occupancy.occumaps = this.subfolders.occupancy.add(this.viewer.occupancy.helpers.occumaps, 'visible').name('occumaps').setValue(occumapsVisible).updateDisplay()
        this.controllers.occupancy.computation = this.subfolders.occupancy.add(this.viewer.occupancy.helpers.computation, 'visible').name('computation').setValue(computationVisible).updateDisplay()
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
