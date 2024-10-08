import * as tf from '@tensorflow/tfjs'

export default class Scharr
{
    constructor()
    {
        this.x = tf.tensor3d([
            [[-3, -10, -3], [-10, -30, -10], [-3, -10, -3]],
            [[ 0,   0,  0], [ 0,    0,   0], [ 0,   0,  0]],
            [[ 3,  10,  3], [ 10,  30,  10], [ 3,  10,  3]]
        ], [3, 3, 3], 'float32').div([82]).div([2])
        
        this.y = tf.tensor3d([
            [[ -3, -10,  -3], [ 0, 0, 0], [  3, 10,  3]],
            [[-10, -30, -10], [ 0, 0, 0], [ 10, 30, 10]],
            [[ -3, -10,  -3], [ 0, 0, 0], [  3, 10,  3]]
        ], [3, 3, 3], 'float32').div([82]).div([2])
        
        this.z =  tf.tensor3d([
            [[ -3, 0,  3], [-10, 0, 10], [ -3, 0,  3]],
            [[-10, 0, 10], [-30, 0, 30], [-10, 0, 10]],
            [[ -3, 0,  3], [-10, 0, 10], [ -3, 0,  3]]
        ], [3, 3, 3], 'float32').div([82]).div([2])
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
    }
}