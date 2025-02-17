import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

export default class TestProcessor
{
    constructor()
    {
        super()

        this.setComputes()
        this.setTensorflow()

        this.computes.maximaMap.tensor
    }

    async setTensorflow()
    {
        // tf.enableProdMode()
        await tf.setBackend('webgl')
        await tf.ready()
        this.trigger('ready')
    }

    setComputes()
    {
        this.computes = 
        {
            intensityMap          : { parameters: null, tensor: null},
            maximaMap             : { parameters: null, tensor: null},
            distanceMap           : { parameters: null, tensor: null},
            anisotropicDistanceMap: { parameters: null, tensor: null},
        }
    }

    destroy() 
    {
        for (const key of Object.keys(this.computes)) 
        {
            const computes = this.computes[key]
            if (!computes) continue

            if (computes.tensor instanceof tf.Tensor) 
            {
                tf.dispose(computes.tensor)
                computes.tensor = null
            }

            computes.parameters = null
            this.computes[key] = null
        }

        this.computes = null
        this.volume.data = null
        this.volume.parameters = null
        this.volume = null

        console.log('MIPProcessor destroyed.')
    }

    async computeDistanceMap(maximaMap, maxIterations)
    {
        // Initialize distance map and previous/next diffusion
        let diffusionMap = tf.tidy(() => tf.variable(tf.clone(maximaMap), true))
        let distanceMap  = tf.tidy(() => tf.variable(tf.zeros(maximaMap.shape, 'int32'), true))

        // Cap max iterations
        maxIterations = Math.min(maxIterations, 256)

        for (let i = 0; i < maxIterations; i++) 
        {
            tf.tidy(() => 
            {
                // Compute distance update
                const distance = tf.scalar(i, 'int32')
                const update = tf.greaterEqual(maximaMap, diffusionMap)

                // Update distance map
                distanceMap.assign(this.mix(distanceMap, distance, update))

                // Compute diffusion map with max pooling
                diffusionMap.assign(tf.maxPool3d(diffusionMap, [3, 3, 3], [1, 1, 1], 'same'))
            })

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }
        
        // Convert variable to tensor
        distanceMap = distanceMap.clone()

        // Cleanup
        tf.disposeVariables()
        await tf.nextFrame()

        return distanceMap
    }

    async computeDiagonalDistanceMap(maximaMap, maxIterations, index)
    {
        const reverse = (variable, index) =>
        {
            tf.tidy(() =>
            {   
                switch (index)
                {
                    case 0: variable.assign(variable.reverse(2).reverse(1).reverse(0)); break // octant (- - -)
                    case 1: variable.assign(variable.reverse(2).reverse(1));            break // octant (- - +)
                    case 2: variable.assign(variable.reverse(2).reverse(0));            break // octant (- + -)
                    case 3: variable.assign(variable.reverse(2));                       break // octant (- + +)
                    case 4: variable.assign(variable.reverse(1).reverse(0));            break // octant (+ - -)
                    case 5: variable.assign(variable.reverse(1));                       break // octant (+ - +)
                    case 6: variable.assign(variable.reverse(0));                       break // octant (+ + -)
                    case 7: variable;                                                   break // octant (+ + +)
                }
            })
        }

        // Initialize distance map and previous/next diffusion
        let diffusionMap = tf.tidy(() => tf.variable(tf.clone(maximaMap), true))
        let distanceMap  = tf.tidy(() => tf.variable(tf.zeros(maximaMap.shape, 'int32'), true))

        // Reflect the map to align with direction
        reverse(diffusionMap, index)

        for (let i = 0; i < maxIterations; i++) 
        {
            tf.tidy(() => 
            {
                // Compute distance update
                const distance = tf.scalar(i, 'int32')
                const update = tf.greaterEqual(maximaMap, diffusionMap)

                // Update distance map
                distanceMap.assign(this.mix(distanceMap, distance, update))

                // Compute diffusion map with max pooling
                diffusionMap.assign(tf.maxPool3d(diffusionMap, [2, 2, 2], [1, 1, 1], 'same'))
            })

            // Allow for garbage collection and prevent blocking
            await tf.nextFrame()
        }

        // Reflect back the distance map
        reverse(distanceMap, index)

        // Convert variable to tensor
        distanceMap = distanceMap.clone()

        // Cleanup
        tf.disposeVariables()
        await tf.nextFrame()

        return distanceMap
    }

    async computeAnisotropicDistanceMap(maximaMap)
    {
        // Octant distance maps
        const distanceMap0 = await this.computeDiagonalDistanceMap(maximaMap, 16, 0)
        const distanceMap1 = await this.computeDiagonalDistanceMap(maximaMap, 16, 1)
        const distanceMap2 = await this.computeDiagonalDistanceMap(maximaMap, 16, 2)
        const distanceMap3 = await this.computeDiagonalDistanceMap(maximaMap, 16, 3)
        const distanceMap4 = await this.computeDiagonalDistanceMap(maximaMap, 16, 4)
        const distanceMap5 = await this.computeDiagonalDistanceMap(maximaMap, 16, 5)
        const distanceMap6 = await this.computeDiagonalDistanceMap(maximaMap, 16, 6)
        const distanceMap7 = await this.computeDiagonalDistanceMap(maximaMap, 16, 7)

        // Bit packing
        const distanceMap01 = tf.tidy(() => tf.add(distanceMap0, distanceMap1.mul(tf.scalar(16, 'int32'))))
        const distanceMap23 = tf.tidy(() => tf.add(distanceMap2, distanceMap3.mul(tf.scalar(16, 'int32'))))
        const distanceMap45 = tf.tidy(() => tf.add(distanceMap4, distanceMap5.mul(tf.scalar(16, 'int32'))))
        const distanceMap67 = tf.tidy(() => tf.add(distanceMap6, distanceMap7.mul(tf.scalar(16, 'int32'))))

        // const map = tf.tidy(() => distanceMap0.minimum(distanceMap1).minimum(distanceMap2).minimum(distanceMap3).minimum(distanceMap4).minimum(distanceMap5).minimum(distanceMap6).minimum(distanceMap7))
        // console.log(map.sub(this.computes.distanceMap.tensor).dataSync())

        // Anisotropic distance map
        const distanceMap = tf.concat([distanceMap01, distanceMap23, distanceMap45, distanceMap67], 3)

        // Disposals
        tf.dispose([distanceMap0, distanceMap1, distanceMap2, distanceMap3, distanceMap4, distanceMap5, distanceMap6, distanceMap7])
        tf.dispose([distanceMap01, distanceMap23, distanceMap45, distanceMap67])

        // Return map
        return distanceMap
    }
    
    mix(tensorA, tensorB, tensorT)
    {
        const difference = tensorB.sub(tensorA)
        const scaled = difference.mul(tensorT)
        tf.dispose(difference)
        const mixed = tensorA.add(scaled)
        tf.dispose(scaled)
        return mixed
    }

}