import * as tf from '@tensorflow/tfjs'

export default class Central
{
    constructor()
    {
        this.areSeparable = false

        this.kernelX = tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2])
        this.kernelY = tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2])
        this.kernelZ = tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2])
    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}