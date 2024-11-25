import * as tf from '@tensorflow/tfjs'

export default class Tetrahedron
{
    constructor()
    {
        this.generate()
    }
    
    generate()
    {
        [this.kernelX, this.kernelY, this.kernelZ] = tf.tidy(() =>
        {
            let kernelX = tf.tensor3d([
                [[ 0, 0, 1], [-1, 0, 1], [-1, 0, 0]],
                [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]],
                [[-1, 0, 0], [-1, 0, 1], [ 0, 0, 1]]
            ], [3, 3, 3], 'float32').div([8]).div([2])
                    
            let kernelY = tf.tensor3d([
                [[ 0, -1, -1], [ 0, 0, 0], [ 1, 1, 0]],
                [[-1, -2, -1], [ 0, 0, 0], [ 1, 2, 1]],
                [[-1, -1,  0], [ 0, 0, 0], [ 0, 1, 1]]
            ], [3, 3, 3], 'float32').div([8]).div([2])
                    
            let kernelZ = tf.tensor3d([
                [[ 0, -1, -1], [-1, -2, -1], [-1, -1,  0]],
                [[ 0,  0,  0], [ 0,  0,  0], [ 0,  0,  0]],
                [[ 1,  1,  0], [ 1,  2,  1], [ 0,  1,  1]]
            ], [3, 3, 3], 'float32').div([8]).div([2])
            
            kernelX = kernelX.expandDims(-1).expandDims(-1)
            kernelY = kernelY.expandDims(-1).expandDims(-1)
            kernelZ = kernelZ.expandDims(-1).expandDims(-1)

            return [kernelX,kernelY, kernelZ]
        }) 
    }

    dispose()
    {
        this.kernelX.dispose()
        this.kernelY.dispose()
        this.kernelZ.dispose()
    }

    destroy()
    {
        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}