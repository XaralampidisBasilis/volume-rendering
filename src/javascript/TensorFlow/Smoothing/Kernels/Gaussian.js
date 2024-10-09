import * as tf from '@tensorflow/tfjs'


export default class Gaussian
/* Sources :
    // https://homepages.inf.ed.ac.uk/rbf/HIPR2/gsmooth.htm
    // https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel
    // https://www.youtube.com/watch?v=SiJpkucGa1o&t=416s&ab_channel=Computerphile
*/
{
    
    constructor(radius)
    {
        this.radius = radius
        this.length = this.radius * 2 + 1
        this.sigma = this.radius / 3
        this.coefficients = this.generate()

        this.x = tf.tensor(this.coefficients, [1, 1, this.length, 1, 1], 'float32')
        this.y = tf.tensor(this.coefficients, [1, this.length, 1, 1, 1], 'float32')
        this.z = tf.tensor(this.coefficients, [this.length, 1, 1, 1, 1], 'float32')
    }
    
    generate()
    {
        let length = this.radius + 1
        let variance = Math.pow(this.sigma, 2)
        const kernel = (t, n) => Math.exp(-(n ** 2) / (2 * t)) / Math.sqrt(2 * Math.PI * t);

        // Create symmetric array by reversing and concatenating
        let coefficients = Array.from({ length: length }, (x, n) => kernel(variance, n))
        return coefficients.toReversed().concat(coefficients.slice(1))
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
        this.sigma = null
        this.coefficients = null
    }
}