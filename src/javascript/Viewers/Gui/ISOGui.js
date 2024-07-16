
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import { throttleByCalls, throttleByDelay } from '../../Utils/Throttle.js'

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
        this.addControllersOccupancy() 
        this.setControllersBindings()  
    }

    addControllersViewer()
    {
        const { viewer } = this.folders

        this.controllers.viewer = {

            visible: viewer.add(this.viewer.mesh, 'visible'),
            
        }
    }

    addControllersRaycast() 
    {
        const { raycast } = this.subfolders
        const u_raycast = this.viewer.material.uniforms.u_raycast.value

        this.controllers.raycast = {

            threshold: raycast.add(u_raycast, 'threshold').min(0).max(1).step(0.0001),
            resolution: raycast.add(u_raycast, 'resolution').min(0).max(2).step(0.001),
            refinements: raycast.add(u_raycast, 'refinements').min(0).max(5).step(1),
            method: raycast.add(u_raycast, 'method').options({ isotropic: 1, directional: 2, traversal: 3 }),
            dithering: raycast.add(u_raycast, 'dithering'),
            skipping: raycast.add(u_raycast, 'skipping')
        }

    }

    addControllersGradient() 
    {
        const { gradient } = this.subfolders
        const u_gradient = this.viewer.material.uniforms.u_gradient.value
    
        this.controllers.gradient = {

            threshold: gradient.add(u_gradient, 'threshold').min(0).max(1).step(0.001),
            resolution: gradient.add(u_gradient, 'resolution').min(0.25).max(2).step(0.001),
            method: gradient.add(u_gradient, 'method').options({ sobel: 1, central: 2, tetrahedron: 3}),
            neighbor: gradient.add(u_gradient, 'neighbor')
        }

    }
    
    addControllersColormap() 
    {
        const { colormap } = this.subfolders
        const u_colormap = this.viewer.material.uniforms.u_colormap.value
        const object = { flip: false }
    
        this.controllers.colormap = {

            low: colormap.add(u_colormap.u_lim, 'x').name('low').min(0).max(1).step(0.001),
            high: colormap.add(u_colormap.u_lim, 'y').name('high').min(0).max(1).step(0.001),
            name: colormap.add(u_colormap, 'name').options(Object.keys(colormapLocations)),
            flip: colormap.add(object, 'flip')
        }

    }
    
    addControllersLighting() 
    {
        const { lighting } = this.subfolders
        const u_lighting = this.viewer.material.uniforms.u_lighting.value
    
        this.controllers.lighting = {

            ka: lighting.add(u_lighting, 'ka').min(0).max(1).step(0.001),
            kd: lighting.add(u_lighting, 'kd').min(0).max(1).step(0.001),
            ks: lighting.add(u_lighting, 'ks').min(0).max(1).step(0.001),
            shininess: lighting.add(u_lighting, 'shininess').min(0).max(40.0).step(0.2),
            power: lighting.add(u_lighting, 'power').min(0).max(2.0).step(0.1),
            model: lighting.add(u_lighting, 'model').options({ phong: 1, blinn: 2, toon: 3, edge: 4}),
            attenuate: lighting.add(u_lighting, 'attenuate'),
            levels: lighting.add(u_lighting, 'levels').min(2).max(255).step(1),
            edge: lighting.add(u_lighting, 'edge').min(0).max(1).step(0.001),
        }
    }
    
    addControllersOccupancy() 
    {
        const { occupancy } = this.subfolders
        const u_occupancy = this.viewer.material.uniforms.u_occupancy.value
    
        this.controllers.occupancy = {

            divisions: occupancy.add(u_occupancy, 'divisions').min(2).max(20).step(1),
            occumaps: occupancy.add(this.viewer.occupancy.helpers.occumaps, 'visible').name('occumaps'),
            computation: occupancy.add(this.viewer.occupancy.helpers.computation, 'visible').name('computation'),
        }

    }
    // controllers bindings

    setControllersBindings()
    {
    
        // raycast threshold controller
        this.controllers.raycast.threshold
        .onChange(() => {
            // displace colormap low based on raycast threshold
            this.displaceColormapLow()

            // displace colormap high based on raycast threshold
            this.displaceColormapHigh()
        })
        .onFinishChange(() => {
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

        // adjust lighting power based on lighting attenuations being on or off
        this.controllers.lighting.attenuate.onChange(() => this.adjustLightingPower())

        // recompute new occupancy based on new divisions
        this.controllers.occupancy.divisions.onFinishChange(() => this.changeOccupancyDivisions())

    }

    displaceColormapLow()
    {
        this.controllers.colormap.low.setValue(
            Math.min(
                this.controllers.colormap.low.getValue(), 
                this.controllers.raycast.threshold.getValue()
            )
        ).updateDisplay()
    }

    displaceColormapHigh()
    {
        this.controllers.colormap.high.setValue(
            Math.max(
                this.controllers.raycast.threshold.getValue(),
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    capColormapLow()
    {
        this.controllers.colormap.low.setValue(
            Math.min(
                this.controllers.colormap.low.getValue(),            
                this.controllers.raycast.threshold.getValue(),
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    capColormapHigh()
    {
        this.controllers.colormap.high.setValue(
            Math.max(
                this.controllers.colormap.low.getValue(), 
                this.controllers.raycast.threshold.getValue(), 
                this.controllers.colormap.high.getValue()
            )
        ).updateDisplay()
    }

    flipColormapRange()
    {
        [this.viewer.material.uniforms.u_colormap.value.u_range.y, this.viewer.material.uniforms.u_colormap.value.u_range.x] = 
        [this.viewer.material.uniforms.u_colormap.value.u_range.x, this.viewer.material.uniforms.u_colormap.value.u_range.y]      
    }

    locateColormapTexture()
    {
        let { v, u_start, u_end } = colormapLocations[this.controllers.colormap.name.getValue()]
        this.viewer.material.uniforms.u_colormap.value.v = v
        this.viewer.material.uniforms.u_colormap.value.u_range.set(u_start, u_end)      
    }

    adjustLightingPower()
    {
        if (this.controllers.lighting.attenuate.getValue())

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

    changeOccupancyDivisions()
    {
        const occumapsVisible = this.controllers.occupancy.occumaps.getValue()
        const computationVisible = this.controllers.occupancy.computation.getValue()

        this.viewer.occupancy.dispose()
        this.viewer.setOccupancy()
        this.viewer.occupancy.compute()

        // destroy and create occupancy visible controller
        this.controllers.occupancy.occumaps.destroy()
        this.controllers.occupancy.computation.destroy()
        
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
