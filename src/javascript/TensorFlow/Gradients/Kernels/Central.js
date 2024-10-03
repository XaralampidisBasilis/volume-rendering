import * as tf from '@tensorflow/tfjs'

export default class Central
{
    constructor()
    {
        this.x = tf.tensor3d([
            [[0, 0, 0], [0, -1, 0], [0, 0, 0]],
            [[0, 0, 0], [0,  0, 0], [0, 0, 0]],
            [[0, 0, 0], [0,  1, 0], [0, 0, 0]]
        ], [3, 3, 3], 'float32').div(2)
        
        this.y = tf.tensor3d([
            [[0,  0, 0], [0, 0, 0], [0, 0, 0]],
            [[0, -1, 0], [0, 0, 0], [0, 1, 0]],
            [[0,  0, 0], [0, 0, 0], [0, 0, 0]]
        ], [3, 3, 3], 'float32').div(2)
        
        this.z =  tf.tensor3d([
            [[0, 0, 0], [ 0, 0, 0], [0, 0, 0]],
            [[0, 0, 0], [-1, 0, 1], [0, 0, 0]],
            [[0, 0, 0], [ 0, 0, 0], [0, 0, 0]]
        ], [3, 3, 3], 'float32').div(2)

    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
    }
}