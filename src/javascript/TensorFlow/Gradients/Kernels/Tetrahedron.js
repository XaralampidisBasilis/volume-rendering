import * as tf from '@tensorflow/tfjs'

export default class Tetrahedron
{
    constructor()
    {
        [this.x, this.y, this.z] = tf.tidy(() =>
        {
            const kernelX = tf.tensor3d([
            [[ 0, 0, 1], [-1, 0, 1], [-1, 0, 0]],
            [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
            [[-1, 0, 0], [-1, 0, 1], [ 0, 0, 1]]
        ], [3, 3, 3], 'float32').div([10]).div([2]).expandDims(-1).expandDims(-1)
                    
            const kernelY = tf.tensor3d([
                [[ 0, -1, -1], [ 0, 0, 0], [ 1, 1, 0]],
                [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
                [[-1, -1,  0], [ 0, 0, 0], [ 0, 1, 1]]
            ], [3, 3, 3], 'float32').div([10]).div([2]).expandDims(-1).expandDims(-1)
                    
            const kernelZ = tf.tensor3d([
                [[ 0, -1, -1], [-1, -2, -1], [-1, -1,  0]],
                [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
                [[ 1,  1,  0], [ 1,  2,  1], [ 0,  1,  1]]
            ], [3, 3, 3], 'float32').div([10]).div([2]).expandDims(-1).expandDims(-1)     

            return [kernelX, kernelY, kernelZ]
        }) 
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
