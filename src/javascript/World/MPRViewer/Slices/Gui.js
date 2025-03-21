import MPRViewer from '../MPRViewer'
import Experience from '../../../Experience'

export default class Gui
{
    constructor()
    {
        this.experience = new Experience()
        this.debug = this.experience.debug
        this.viewer = this.experience.viewer
        this.slices = this.viewer.slices

        if (this.debug.active)
        {
            this.setGui()
        }
    }

    setGui()
    {
        this.handle = this.debug.ui.addFolder('Slices').open()
        
        this.handle.add(this.slices.group, 'x').min(0).max(this.slices.parameters.x).step(0.001).onChange(() => this.slices.update())
        this.handle.add(this.slices.group, 'y').min(0).max(this.slices.parameters.y).step(0.001).onChange(() => this.slices.update())
        this.handle.add(this.slices.group, 'z').min(0).max(this.slices.parameters.z).step(0.001).onChange(() => this.slices.update())
        this.handle.add(this.slices.group.children[0], 'visibleX').onChange(() => this.slices.update())
        this.handle.add(this.slices.group.children[1], 'visibleY').onChange(() => this.slices.update())
        this.handle.add(this.slices.group.children[2], 'visibleZ').onChange(() => this.slices.update())
        this.handle.add(this.slices.group, 'visible')
    }
    
    destroy() 
    {
        this.handle.destroy()

        this.experience = null
        this.debug = null
        this.viewer = null
        this.slices = null
        this.handle = null
    }
    
}
