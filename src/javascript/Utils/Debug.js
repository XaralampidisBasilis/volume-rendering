import GUI from 'lil-gui'

export default class Debug
{
    constructor()
    {
        this.active = window.location.hash === '#debug'

        if(this.active)
        {
            this.ui = new GUI()
        }
    }

    getController(gui, name) 
    {
        // Check if the controller is in the main GUI
        for (const controller of gui.controllersRecursive()) 
        {
            if (controller._name === name)
                return controller        
        }

        // Return null if the controller was not found
        return null
    }

    getFolder(gui, name) 
    {
        // Check if the controller is in the main GUI
        for (const folder of gui.foldersRecursive()) 
        {
            if (folder._name === name)
                return folder        
        }

        // Return null if the controller was not found
        return null
    }
}