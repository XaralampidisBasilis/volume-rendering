import Experience from '../Experience'
import ISOViewer from '../Viewers/ISOViewer'

export default class World
{
    constructor()
    {
        this.experience = new Experience()
        this.scene = this.experience.scene
        this.resources = this.experience.resources
        this.camera = this.experience.camera

        // Wait for resources
        this.resources.on('ready', () =>
        {
            this.viewer = new ISOViewer()
            this.camera.instance.position.fromArray(this.resources.items.volumeNifti.size)
        })
    }

    update()
    {
        if(this.viewer)
            this.viewer.update()
    }

    destroy()
    {
        if(this.viewer)
            this.viewer.destroy()
    }
}