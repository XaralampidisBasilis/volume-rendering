import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Chebyshev from './Filter/Chebyshev'

// assumes intensity data 3D, and data3DTexture
export default class ComputeDistances
{   
    constructor(viewer)
    { 
        this.viewer = viewer
        this.parameters = this.viewer.parameters

        this.filter = new Chebyshev()
        this.minValue = this.viewer.material.uniforms.u_raymarch.value.min_sample_value
    }

    async compute()
    {               
        tf.tidy(() => 
        {
            const division = 2
            const divisions = new Array(3).fill(division)

            const spacing = this.parameters.volume.spacing.toArray().toReversed().concat(1)
            const condition = this.viewer.tensors.volume.greater([this.minValue])
      
            const [minCoords, maxCoords] = this.argRange(condition)
            const [minPosition, maxPosition] = [minCoords.mul(spacing), maxCoords.mul(spacing)]

            const occupancy = this.padCeil(condition, division)
            condition.dispose()

            const occumap = occupancy.maxPool3d(divisions, divisions, 'same')
            occupancy.dispose()

            const distmap = this.distances(occumap)
            occumap.dispose()
            
        })

        return { results: this.results }
    }

    dataSync()  
    {
    }

    update()
    {
        this.minValue = this.viewer.material.uniforms.u_raymarch.value.min_sample_value
    }

    destroy() 
    {
        this.data = null
        this.results = null
        this.viewer = null
        this.parameters = null
        this.minValue = null

        console.log('ComputeOccupancy destroyed and resources freed.')
    }

    // helper tensor functions

    padCeil(tensor, divisions)
    {
        const ceilDiv = (dim) => Math.ceil(dim / divisions)
        const padShape = tensor.shape.map(ceilDiv)
        const padded = tensor.pad(padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
        tensor.dispose()
        return padded
    }
    
    argRange1d(tensor, axis)
    {
        const axes = [0, 1, 2, 3].toSpliced(axis, 1)
        const dimension = tensor.shape[axis]
        const condition = tensor.any(axes)
        const minInd = condition.argMax(0)
        const maxInd = tf.sub(dimension, condition.reverse().argMax(0))
        condition.dispose()
        return [minInd, maxInd] 
    }

    argRange(tensor)
    {
        const [minInd0, maxInd0] = this.argRange1d(tensor, 0)
        const [minInd1, maxInd1] = this.argRange1d(tensor, 1)
        const [minInd2, maxInd2] = this.argRange1d(tensor, 2)
        const [minInd3, maxInd3] = this.argRange1d(tensor, 3)
        const minCoords = tf.stack([minInd0, minInd1, minInd2, minInd3], 0)    
        const maxCoords = tf.stack([maxInd0, maxInd1, maxInd2, maxInd3], 0) 
        tf.dispose([minInd0, minInd1, minInd2, minInd3])
        tf.dispose([maxInd0, maxInd1, maxInd2, maxInd3])
        return [minCoords, maxCoords]
    }

    distances(occumap)
    {
        const one = tf.scalar(1)
        const zero = tf.scalar(0)

        let distmap = tf.tidy(() => {
            const ones = occumap.equal(one) 
            const zeros = occumap.equal(zero) 
            return ones.mul(zero).add(zeros.mul([255])) 
        })
      
        for (let iter = 0; iter < 255; iter++) 
        {
            distmap = tf.tidy(() => 
            {
                const convolved = distmap.conv3d(this.filter.kernel, 1, 'same')
                const distmapTmp = tf.minimum(distmap, convolved.add(one))
                convolved.dispose()
                distmap.dispose()
                return distmapTmp
            })
        }

        distmap = tf.tidy(() => {
            const mask = distmap.less([255])
            return distmap.mul(mask).add(one)
        })

        zero.dispose()
        one.dispose()

       return distmap
    }
}