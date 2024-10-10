import * as tf from '@tensorflow/tfjs'

export default class Sobel
/* Sources
    https://www.wikiwand.com/en/articles/Sobel_operator
*/
{
    constructor()
    {  
        [this.kernelX, this.kernelY, this.kernelZ] = tf.tidy(() => 
        {
            this.areSeparable = true

            const kernelX = {
                separableX: tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                separableY: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                separableZ: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
            }

            const kernelY = {
                separableX: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([4]),
                separableY: tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                separableZ: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
            }

            const kernelZ = {
                separableX: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([4]),
                separableY: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                separableZ: tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2]),
            }

            return [kernelX, kernelY, kernelZ]
        })
    }

    dispose()
    {
        this.kernelX.separableX.dispose()
        this.kernelX.separableY.dispose()
        this.kernelX.separableZ.dispose()

        this.kernelY.separableX.dispose()
        this.kernelY.separableY.dispose()
        this.kernelY.separableZ.dispose()

        this.kernelZ.separableX.dispose()
        this.kernelZ.separableY.dispose()
        this.kernelZ.separableZ.dispose()

        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}
