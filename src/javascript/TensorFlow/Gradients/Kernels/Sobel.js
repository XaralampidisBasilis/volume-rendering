import * as tf from '@tensorflow/tfjs'

export default class Sobel
{
    constructor()
    {
        [this.x, this.y, this.z] = tf.tidy(() => 
        {
            const kernelX = {

                combined: tf.tensor3d([
                    [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
                    [[-2, 0, 2], [-4, 0, 4], [-2, 0, 2]],
                    [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
                ], 
                [3, 3, 3], 'float32').div([16]).div([2]).expandDims(-1).expandDims(-1),

                separable: {
                    x: tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                    y: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                    z: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
                },
            }

            const kernelY = {

                combined: tf.tensor3d([
                    [[-1, -2, -1], [0, 0, 0], [1, 2, 1]],
                    [[-2, -4, -2], [0, 0, 0], [2, 4, 2]],
                    [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
                ], 
                [3, 3, 3], 'float32').div([16]).div([2]).expandDims(-1).expandDims(-1),
    
                separable: {
                    x: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([4]),
                    y: tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                    z: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
                },
            }

            const kernelZ = {

                combined: tf.tensor3d([
                    [[-1, -2, -1], [-2, -4, -2], [-1, -2, -1]],
                    [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
                    [[ 1,  2,  1], [ 2,  4,  2], [ 1,  2,  1]]
                ], 
                [3, 3, 3], 'float32').div([16]).div([2]).expandDims(-1).expandDims(-1),

                separable: {
                    x: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                    y: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                    z: tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
                },
            }

            return [kernelX, kernelY, kernelZ]
        })
    }

    dispose()
    {
        this.x.combined.dispose()
        this.y.combined.dispose()
        this.z.combined.dispose()

        this.x.separable.x.dispose()
        this.x.separable.y.dispose()
        this.x.separable.z.dispose()

        this.y.separable.x.dispose()
        this.y.separable.y.dispose()
        this.y.separable.z.dispose()

        this.z.separable.x.dispose()
        this.z.separable.y.dispose()
        this.z.separable.z.dispose()

        this.kernelX = null
        this.kernelY = null
        this.kernelY = null
    }
}
