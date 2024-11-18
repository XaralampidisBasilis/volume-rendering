import * as tf from '@tensorflow/tfjs'

export default class Chebyshev
{
    constructor()
    {
        this.generate()
    }
    
    generate()
    {
        this.kernel = tf.tidy(() =>
        {
            let kernel = tf.tensor3d([
                [[1, 1, 1], [1, 1, 1], [1, 1, 1]],
                [[1, 1, 1], [1, 0, 1], [1, 1, 1]],
                [[1, 1, 1], [1, 1, 1], [1, 1, 1]]
            ], [3, 3, 3], 'float32')
     
            kernel = kernel.expandDims(-1).expandDims(-1)

            return kernel
        }) 
    }

    dispose()
    {
        this.kernel.dispose()
    }

    destroy()
    {
        this.kernel = null
    }
}