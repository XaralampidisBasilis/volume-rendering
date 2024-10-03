import * as tf from '@tensorflow/tfjs'

export default class Tetrahedron
{
    constructor()
    {
        this.kernelX = tf.tensor3d([
            [[ 0, -1, -1], [-1, -2, -1], [-1, -1,  0]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  1,  0], [ 1,  2,  1], [ 0,  1,  1]]
        ], [3, 3, 3], 'float32').div(10).div(2)
        
        this.kernelY = tf.tensor3d([
            [[ 0, -1, -1], [ 0, 0, 0], [ 1, 1, 0]],
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
            [[-1, -1,  0], [ 0, 0, 0], [ 0, 1, 1]]
        ], [3, 3, 3], 'float32').div(10).div(2)
        
        this.kernelZ =  tf.tensor3d([
            [[ 0, 0, 1], [-1, 0, 1], [-1, 0, 0]],
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
            [[-1, 0, 0], [-1, 0, 1], [ 0, 0, 1]]
        ], [3, 3, 3], 'float32').div(10).div(2)
    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
    }
}
