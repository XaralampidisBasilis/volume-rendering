
import { colormapLocations } from '../../../static/textures/colormaps/colormaps.js'
import { throttleByCalls } from '../Utils/Throttle.js'

export default class ISOGui
{
    constructor(debug, viewer)
    {
        this.debug = debug
        this.viewer = viewer

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
        this.addRaycastControllers() 
        this.addGradientControllers() 
        this.addColormapControllers() 
        this.addLightingControllers() 
        // this.addOccupancyControllers() 
        this.setControllerBindings()  
    }

    addRaycastControllers() {

        const { raycast } = this.subfolders
        const u_raycast = this.viewer.material.uniforms.u_raycast.value

        this.controllers.raycast = {

            threshold: raycast.add(u_raycast, 'threshold')
                .min(0)
                .max(1)
                .step(0.0001),

            resolution: raycast.add(u_raycast, 'resolution')
                .min(0)
                .max(2)
                .step(0.001),

            refinements: raycast.add(u_raycast, 'refinements')
                .min(1)
                .max(5)
                .step(1),

            stride: raycast.add(u_raycast, 'stride')
                .options({ isotropic: 1, directional: 2, traversal: 3 }),

            dither: raycast.add(u_raycast, 'dither')
        }

    }

    addGradientControllers() {

        const { gradient } = this.subfolders
        const u_gradient = this.viewer.material.uniforms.u_gradient.value
    
        this.controllers.gradient = {

            resolution: gradient.add(u_gradient, 'resolution')
                .min(0.25)
                .max(2)
                .step(0.001),
                
            method: gradient.add(u_gradient, 'method')
                .options({ sobel: 1, central: 2, tetrahedron: 3}),

            neighbor: gradient.add(u_gradient, 'neighbor')
        }

    }
    
    addColormapControllers() {

        const { colormap } = this.subfolders
        const u_colormap = this.viewer.material.uniforms.u_colormap.value
        const object = { flip: false }
    
        this.controllers.colormap = {

            low: colormap.add(u_colormap.u_lim, 'x')
                .name('low')
                .min(0)
                .max(1)
                .step(0.001),

            high: colormap.add(u_colormap.u_lim, 'y')
                .name('high')
                .min(0)
                .max(1)
                .step(0.001),

            name: colormap.add(u_colormap, 'name')
                .name('name')
                .options(Object.keys(colormapLocations)),

            flip: colormap.add(object, 'flip')
                .name('flip')
        }

    }
    
    addLightingControllers() {

        const { lighting } = this.subfolders
        const u_lighting = this.viewer.material.uniforms.u_lighting.value
    
        this.controllers.lighting = {

            ka: lighting.add(u_lighting, 'ka')
                .min(0)
                .max(1)
                .step(0.001),

            kd: lighting.add(u_lighting, 'kd')
                .min(0)
                .max(1)
                .step(0.001),

            ks: lighting.add(u_lighting, 'ks')
                .min(0)
                .max(1)
                .step(0.001),

            shininess: lighting.add(u_lighting, 'shininess')
                .min(0)
                .max(40.0)
                .step(0.2),

            power: lighting.add(u_lighting, 'power')
                .min(0)
                .max(2.0)
                .step(0.1),

            model: lighting.add(u_lighting, 'model')
                .options({ phong: 1, blinn: 2}),

            attenuate: lighting.add(u_lighting, 'attenuate')
        }
    }
    
    addOccupancyControllers() {

        const { occupancy } = this.subfolders
        const u_occupancy = this.viewer.material.uniforms.u_occupancy.value
    
        this.controllers.occupancy = {

            resolution: occupancy.add(u_occupancy, 'resolution')
                .min(2)
                .max(64)
                .step(1),

            method: occupancy.add(u_occupancy, 'method')
                .options({ monotree: 1, octree: 2}),

            visible: occupancy.add(this.viewer.occupancy.compute.debug.material, 'visible')
                .name('visible')
        }

    }
    // controllers bindings

    setControllerBindings()
    {
        // throttled compute occupancy map and bounding box based on raycast threshold
        const computeThresholdOccupancyThrottled =  throttleByCalls(() => this.computeThresholdOccupancy(), 5)
    
        // raycast threshold controller
        this.controllers.raycast.threshold.onChange(() => 
        {
            // displace colormap low based on raycast threshold
            this.displaceColormapLow()

            // displace colormap high based on raycast threshold
            this.displaceColormapHigh()
            
            // throttled compute occupancy map and bounding box based on raycast threshold
            // computeThresholdOccupancyThrottled()
        })
        // .onFinishChange(() => this.computeThresholdOccupancy())

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

        // recompute new occupancy based on new resolution
        // this.controllers.occupancy.resolution.onFinishChange(() => this.recomputeResolutionOccupancy())

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

    computeThresholdOccupancy()
    {
        this.viewer.occupancy.compute(this.controllers.raycast.threshold.getValue())
        this.viewer.material.uniforms.u_sampler.value.occupancy = this.viewer.occupancy.computation.texture
        this.viewer.material.uniforms.u_occupancy.value.box_min = this.viewer.occupancy.box.min
        this.viewer.material.uniforms.u_occupancy.value.box_max = this.viewer.occupancy.box.max
    }

    recomputeResolutionOccupancy()
    {
        const visible = this.controllers.occupancy.visible.getValue()

        this.viewer.occupancy.dispose()
        this.viewer.setOccupancy()

        // destroy and create occupancy visible controller
        this.controllers.occupancy.visible.destroy()
        this.controllers.occupancy.visible = this.subfolders.occupancy
            .add(this.viewer.occupancy.compute.debug.material, 'visible')
            .name('visible')
            .setValue(visible)
            .updateDisplay()

        this.computeThresholdOccupancy()
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
