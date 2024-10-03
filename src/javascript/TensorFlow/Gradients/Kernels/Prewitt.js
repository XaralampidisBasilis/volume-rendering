import * as tf from '@tensorflow/tfjs'

export default class Prewitt
{
    constructor()
    {
        this.kernelX = tf.tensor3d([
            [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  1,  1], [ 1,  1,  1], [ 1,  1,  1]]
        ], [3, 3, 3], 'float32').div(9).div(2)
        
        this.kernelY = tf.tensor3d([
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]],
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]],
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]]
        ], [3, 3, 3], 'float32').div(9).div(2)
        
        this.kernelZ =  tf.tensor3d([
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]],
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]],
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]]
        ], [3, 3, 3], 'float32').div(9).div(2)
    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
    }
}