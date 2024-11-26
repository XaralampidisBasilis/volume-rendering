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
        this.generate()
    }

    generator()
    {
        return 1 / this.length
    }
    
    generate()
    {
        this.kernel = tf.tidy(() =>
        {
            this.coefficients = Array.from({ length: this.length }, (_, n) => this.generator(n))

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
        this.coefficients = null

        this.kernel.isSeparable = null
        this.kernel.separableX = null
        this.kernel.separableY = null
        this.kernel.separableZ = null
        this.kernel.combined = null 
        this.kernel = null
    }
}