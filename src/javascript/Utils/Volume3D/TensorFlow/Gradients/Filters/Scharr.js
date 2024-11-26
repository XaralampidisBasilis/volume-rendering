import * as tf from '@tensorflow/tfjs'

export default class Scharr
/* Sources
    https://www.wikiwand.com/en/articles/Sobel_operator
*/
{
    constructor()
    {
        this.generate()
    }

    generate()
    {
        
    }

    dispose()
    {
        this.kernelX.combined.dispose()
        this.kernelY.combined.dispose()
        this.kernelZ.combined.dispose()

        this.kernelX.separableX.dispose()
        this.kernelX.separableY.dispose()
        this.kernelX.separableZ.dispose()

        this.kernelY.separableX.dispose()
        this.kernelY.separableY.dispose()
        this.kernelY.separableZ.dispose()

        this.kernelZ.separableX.dispose()
        this.kernelZ.separableY.dispose()
        this.kernelZ.separableZ.dispose()
    }

    destroy()
    {
        this.kernelX.separableX = null
        this.kernelX.separableY = null
        this.kernelX.separableZ = null
        this.kernelX.combined = null

        this.kernelY.separableX = null
        this.kernelY.separableY = null
        this.kernelY.separableZ = null
        this.kernelY.combined = null

        this.kernelZ.separableX = null
        this.kernelZ.separableY = null
        this.kernelZ.separableZ = null
        this.kernelZ.combined = null

        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}