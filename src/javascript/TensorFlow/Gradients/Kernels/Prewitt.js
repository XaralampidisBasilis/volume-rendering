import * as tf from '@tensorflow/tfjs'

export default class Prewitt
{
    constructor()
    {
        this.x =  tf.tensor3d([
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]],
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]],
            [[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]]
        ], [3, 3, 3], 'float32').div([9]).div([2])
        
        this.y = tf.tensor3d([
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]],
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]],
            [[-1, -1, -1], [ 0, 0, 0], [ 1, 1, 1]]
        ], [3, 3, 3], 'float32').div([9]).div([2])
        
        this.z = tf.tensor3d([
            [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  1,  1], [ 1,  1,  1], [ 1,  1,  1]]
        ], [3, 3, 3], 'float32').div([9]).div([2])        
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
    }
}