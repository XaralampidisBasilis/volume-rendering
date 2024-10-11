import * as tf from '@tensorflow/tfjs'

export default class Prewitt
/* Sources
    https://www.wikiwand.com/en/articles/Prewitt_operator
*/
{
    constructor()
    {        
        this.generate()
    }

    generate()
    {
        [this.kernelX, this.kernelY, this.kernelZ] = tf.tidy(() =>
        {
            const kernelX = {
                isSeparable: true,
                separableX: tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                separableY: tf.tensor5d([ 1, 1, 1], [1, 3, 1, 1, 1], 'float32').div([3]),
                separableZ: tf.tensor5d([ 1, 1, 1], [3, 1, 1, 1, 1], 'float32').div([3]),
            }

            const kernelY = {
                isSeparable: true,
                separableX: tf.tensor5d([ 1, 1, 1], [1, 1, 3, 1, 1], 'float32').div([3]),
                separableY: tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                separableZ: tf.tensor5d([ 1, 1, 1], [3, 1, 1, 1, 1], 'float32').div([3]),
            }

            const kernelZ = {
                isSeparable: true,
                separableX: tf.tensor5d([ 1, 1, 1], [1, 1, 3, 1, 1], 'float32').div([3]),
                separableY: tf.tensor5d([ 1, 1, 1], [1, 3, 1, 1, 1], 'float32').div([3]),
                separableZ: tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2]),
            }

            kernelX.combined = kernelX.separableX.mul(kernelX.separableY).mul(kernelX.separableZ)
            kernelY.combined = kernelY.separableX.mul(kernelY.separableY).mul(kernelY.separableZ)
            kernelZ.combined = kernelZ.separableX.mul(kernelZ.separableY).mul(kernelZ.separableZ)

            return [kernelX,kernelY, kernelZ]
        })
    }

    dispose()
    {
        this.kernelX.combined.dispose()
        this.kernelY.combined.dispose()
        this.kernelZ.combined.dispose()

        this.kernelX.separableX.dispose()
        this.kernelX.separableY.dispose()
        this.kernelX.separableZ.dispose()

        this.kernelY.separableX.dispose()
        this.kernelY.separableY.dispose()
        this.kernelY.separableZ.dispose()

        this.kernelZ.separableX.dispose()
        this.kernelZ.separableY.dispose()
        this.kernelZ.separableZ.dispose()
    }

    destroy()
    {
        this.kernelX.separableX = null
        this.kernelX.separableY = null
        this.kernelX.separableZ = null
        this.kernelX.combined = null

        this.kernelY.separableX = null
        this.kernelY.separableY = null
        this.kernelY.separableZ = null
        this.kernelY.combined = null

        this.kernelZ.separableX = null
        this.kernelZ.separableY = null
        this.kernelZ.separableZ = null
        this.kernelZ.combined = null

        this.kernelX = null
        this.kernelY = null
        this.kernelZ = null
    }
}