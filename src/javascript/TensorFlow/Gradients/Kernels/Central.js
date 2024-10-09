import * as tf from '@tensorflow/tfjs'

export default class Central
{
    constructor()
    {
        this.x = tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2])
        this.y = tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2])
        this.z = tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2])
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
        this.x = null
        this.y = null
        this.z = null
    }
}