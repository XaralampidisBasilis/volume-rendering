import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import Scharr from './Kernels/Scharr'

// assumes intensity data 3D, and data3DTexture
export default class ComputeGradientsTF
{   
    constructor(viewer)
    {
        this.viewer = viewer
        this.parameters = this.viewer.parameters

        this.setKernels()
        this.compute()
        this.dispose()
    }

    setKernels()
    {
        this.kernels = new Scharr()
    }

    compute()
    {   
        this.tensor = tf.tidy(() => 
        {
            const filterX = this.kernels.x.expandDims(-1).expandDims(-1)
            const filterY = this.kernels.y.expandDims(-1).expandDims(-1)
            const filterZ = this.kernels.z.expandDims(-1).expandDims(-1)

            const gradientX = tf.conv3d(this.viewer.tensors.volume, filterX, 1, 'same').div(this.parameters.volume.spacing.x)
            const gradientY = tf.conv3d(this.viewer.tensors.volume, filterY, 1, 'same').div(this.parameters.volume.spacing.y)
            const gradientZ = tf.conv3d(this.viewer.tensors.volume, filterZ, 1, 'same').div(this.parameters.volume.spacing.z)
            filterX.dispose()
            filterY.dispose()
            filterZ.dispose()

            const gradients = tf.concat([gradientX, gradientY, gradientZ], 3)
            gradientX.dispose()
            gradientY.dispose()
            gradientZ.dispose()

            const gradientsNorm = tf.norm(gradients, 'euclidean', 3).reshape([-1])
            const k = Math.floor(gradientsNorm.size * 0.001)
            const maxNorm = tf.topk(gradientsNorm, k, true).values.min()
            gradientsNorm.dispose()

            const gradientsUint8 = gradients.div(maxNorm).mul(255).cast('int32')
            gradients.dispose()

            return gradientsUint8
        })

    }

    dispose()
    {
        this.kernels.dispose()
    }

}