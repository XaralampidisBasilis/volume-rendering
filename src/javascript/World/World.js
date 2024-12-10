import Experience from '../Experience'
import ISOViewer from '../Viewers/ISOViewer/ISOViewer'
import MIPViewer from '../Viewers/MIPViewer/MIPViewer'
import EventEmitter from '../Utils/EventEmitter'

export default class World extends EventEmitter
{
    constructor()
    {
        super()

        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.camera = this.experience.camera

        // Wait for resources
        this.resources.on('ready', () =>
        {
            // Wait for viewer
            this.viewer = new MIPViewer()
            this.viewer.on('ready', () => 
            {
                this.camera.instance.position.copy(this.viewer.parameters.volume.size)
                this.trigger('ready')
            })
        })
    }

    update()
    {
    }

    destroy()
    {
        if(this.viewer)
            this.viewer.destroy()
    }
}