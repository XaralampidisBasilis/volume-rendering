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
        this.world = this.experience.world

        // Wait for resources
        this.resources.on('ready', () =>
        {
            this.viewer = new ISOViewer()
            this.camera.instance.position.fromArray(this.viewer.resource.volume.size)
        })
    }

    update()
    {
        if(this.viewer)
            this.viewer.update()
    }
}