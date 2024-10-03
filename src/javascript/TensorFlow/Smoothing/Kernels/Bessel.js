import * as tf from '@tensorflow/tfjs'

export default class Central
{
    constructor()
    {
        this.x = tf.tensor3d([
            [[-1, -2, -1], [-2, -4, -2], [-1, -2, -1]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  2,  1], [ 2,  4,  2], [ 1,  2,  1]]
        ], [3, 3, 3], 'float32').div(16)
        
        this.y = tf.tensor3d([
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
            [[-2, -4, -2], [ 0, 0, 0], [ 2, 4, 2]],
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]]
        ], [3, 3, 3], 'float32').div(16)
        
        this.z =  tf.tensor3d([
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
            [[-2, 0, 2], [-4, 0, 4], [-2, 0, 2]],
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
        ], [3, 3, 3], 'float32').div(16)

    }
}