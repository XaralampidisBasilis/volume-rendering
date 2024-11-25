import * as tf from '@tensorflow/tfjs'
import BESSEL from 'bessel'

export default class Bessel
/* Sources :
    // https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel
    // https://www.youtube.com/watch?v=SiJpkucGa1o&t=416s&ab_channel=Computerphile
*/
{
    constructor(radius)
    {
        this.radius = radius
        this.length = this.radius * 2 + 1
        this.sigma = this.radius / 3
        this.variance = this.sigma ** 2
        this.generate()
    }

    generator(n)
    {
        return Math.exp(-this.variance) * BESSEL.besseli(this.variance, n)
    }

    generate()
    {        
        this.kernel = tf.tidy(() =>
        {
            const length = this.radius + 1
            this.coefficients = Array.from({ length: length }, (_, n) => this.generator(n))
            this.coefficients = this.coefficients.toReversed().concat(this.coefficients.slice(1))
        
            const kernel = {
                isSeparable: true,
                separableX: tf.tensor5d(this.coefficients, [1, 1, this.length, 1, 1], 'float32'),
                separableY: tf.tensor5d(this.coefficients, [1, this.length, 1, 1, 1], 'float32'),
                separableZ: tf.tensor5d(this.coefficients, [this.length, 1, 1, 1, 1], 'float32'),
            }
            
            kernel.combined = kernel.separableX.mul(kernel.separableY).mul(kernel.separableZ)
            
            return kernel
        })
    }

    dispose()
    {
        this.kernel.separableX.dispose()
        this.kernel.separableY.dispose()
        this.kernel.separableZ.dispose()
        this.kernel.combined.dispose()
    }

    destroy()
    {       
        this.radius = null
        this.length = null
        this.sigma = null
        this.variance = null
        this.coefficients = null
        
        this.kernel.isSeparable = null
        this.kernel.separableX = null
        this.kernel.separableY = null
        this.kernel.separableZ = null
        this.kernel.combined = null
        this.kernel = null
    }
}