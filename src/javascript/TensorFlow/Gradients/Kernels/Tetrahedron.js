import * as tf from '@tensorflow/tfjs'

export default class Tetrahedron
{
    constructor()
    {
        this.x = tf.tensor3d([
            [[ 0, -1, -1], [-1, -2, -1], [-1, -1,  0]],
            [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
            [[ 1,  1,  0], [ 1,  2,  1], [ 0,  1,  1]]
        ], [3, 3, 3], 'float32').div([10]).div([2])
        
        this.y = tf.tensor3d([
            [[ 0, -1, -1], [ 0, 0, 0], [ 1, 1, 0]],
            [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
            [[-1, -1,  0], [ 0, 0, 0], [ 0, 1, 1]]
        ], [3, 3, 3], 'float32').div([10]).div([2])
        
        this.z =  tf.tensor3d([
            [[ 0, 0, 1], [-1, 0, 1], [-1, 0, 0]],
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
            [[-1, 0, 0], [-1, 0, 1], [ 0, 0, 1]]
        ], [3, 3, 3], 'float32').div([10]).div([2])
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
    }
}
