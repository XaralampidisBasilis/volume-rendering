import * as tf from '@tensorflow/tfjs'

export default class Tetrahedron
{
    constructor()
    {
        [this.kernelX, this.kernelY, this.kernelZ] = tf.tidy(() =>
        {
            this.areSeparable = false

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
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}
