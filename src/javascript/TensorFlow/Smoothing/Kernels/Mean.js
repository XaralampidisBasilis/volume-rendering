import * as tf from '@tensorflow/tfjs'

export default class Mean
{
    constructor(radius)
    {
        this.kernel = tf.ones([radius, radius, radius]).div(radius ** 3)
    }

    dispose()
    {
        this.kernel.dispose()
    }
}