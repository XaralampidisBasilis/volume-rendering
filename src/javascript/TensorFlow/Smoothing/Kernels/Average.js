import * as tf from '@tensorflow/tfjs'

export default class Average
/* Sources :
    // https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm
    // https://www.youtube.com/watch?v=SiJpkucGa1o&t=416s&ab_channel=Computerphile
*/
{
    constructor(radius)
    {
        this.radius = radius
        this.length = this.radius * 2 + 1
        this.coefficients = this.generate()

        this.x = tf.tensor5d(this.coefficients, [1, 1, this.length, 1, 1], 'float32')
        this.y = tf.tensor5d(this.coefficients, [1, this.length, 1, 1, 1], 'float32')
        this.z = tf.tensor5d(this.coefficients, [this.length, 1, 1, 1, 1], 'float32')
    }
    
    generate()
    {
        return  Array.from({ length: this.length }, () => 1 / this.length)
    }

    dispose()
    {
        this.x.dispose()
        this.y.dispose()
        this.z.dispose()
        this.x = null
        this.y = null
        this.z = null
        this.radius = null
        this.length = null
        this.coefficients = null
    }
}