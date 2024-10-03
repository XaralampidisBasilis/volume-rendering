import * as tf from '@tensorflow/tfjs'

export default class Sobel
{
    constructor()
    {
        this.x = tf.tensor3d([
            [[-1, -2, -1], [-2, -4, -2], [-1, -2, -1]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  2,  1], [ 2,  4,  2], [ 1,  2,  1]]
        ], [3, 3, 3], 'float32').div(16).div(2)
        
        this.y = tf.tensor3d([
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
            [[-2, -4, -2], [ 0, 0, 0], [ 2, 4, 2]],
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]]
        ], [3, 3, 3], 'float32').div(16).div(2)
        
        this.z =  tf.tensor3d([
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
            [[-2, 0, 2], [-4, 0, 4], [-2, 0, 2]],
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
        ], [3, 3, 3], 'float32').div(16).div(2)
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
    }
}
