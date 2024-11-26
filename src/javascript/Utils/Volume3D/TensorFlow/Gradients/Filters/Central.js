import * as tf from '@tensorflow/tfjs'

export default class Central
{
    constructor()
    {
        this.generate()
    }

    generate()
    {
        [this.kernelX, this.kernelY, this.kernelZ] = tf.tidy(() =>
        {
            const kernelX = tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2])
            const kernelY = tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2])
            const kernelZ = tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2])
            
            return [kernelX,kernelY, kernelZ]
        })
    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
    }

    destroy()
    {
        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}