import * as tf from '@tensorflow/tfjs'

export default class Scharr
{
    constructor()
    {
        [this.x, this.y, this.z] = tf.tidy(() =>
        {
            const kernelX = tf.tensor3d([
                [[ -3, 0,  3], [-10, 0, 10], [ -3, 0,  3]],
                [[-10, 0, 10], [-30, 0, 30], [-10, 0, 10]],
                [[ -3, 0,  3], [-10, 0, 10], [ -3, 0,  3]]
            ], [3, 3, 3], 'float32').div([82]).div([2]).expandDims(-1).expandDims(-1)
                    
            const kernelY = tf.tensor3d([
                [[ -3, -10,  -3], [ 0, 0, 0], [  3, 10,  3]],
                [[-10, -30, -10], [ 0, 0, 0], [ 10, 30, 10]],
                [[ -3, -10,  -3], [ 0, 0, 0], [  3, 10,  3]]
            ], [3, 3, 3], 'float32').div([82]).div([2]).expandDims(-1).expandDims(-1)
                    
            const kernelZ = tf.tensor3d([
                [[-3, -10, -3], [-10, -30, -10], [-3, -10, -3]],
                [[ 0,   0,  0], [ 0,    0,   0], [ 0,   0,  0]],
                [[ 3,  10,  3], [ 10,  30,  10], [ 3,  10,  3]]
            ], [3, 3, 3], 'float32').div([82]).div([2]).expandDims(-1).expandDims(-1)     

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