import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import everpolate from 'everpolate'
import BESSEL from 'bessel'

export function histcounts(tensor)
{
    return tf.tidy(() =>
    { 
        // compute interquartile range (IQR)
        const q25 = quantile(tensor, 25)
        const q75 = quantile(tensor, 75)
        const IQR = q75.sub(q25)
    
        // number of data points
        const N = tensor.size
    
        // compute bin width using Freedman-Diaconis Rule
        const binWidth = IQR.mul(2).div(tf.scalar(Math.cbrt(N)))
    
        // compute the min and max values of the tensor
        const min = tensor.min()
        const max = tensor.max()
        const range = max.sub(min)

        // compute number of bins
        const numBins = range.div(binWidth).ceil().arraySync()
            
        return numBins
    })
}

export function approximateHistogram(tensor, numBins, sampleRate) 
{
    return tf.tidy(() => 
    {
        const flatTensor = tensor.flatten()
        
        // Compute the min and max values of the tensor
        const tensorMin = flatTensor.min()
        const tensorMax = flatTensor.max()

        // Subsample the tensor
        sampleRate = sampleRate ?? 0.01
        const sampleSize = Math.max(1, Math.floor(flatTensor.size * sampleRate))
        const sampleIndices = tf.randomUniform([sampleSize], 0, flatTensor.size, 'int32')
        const subTensor = tf.gather(flatTensor, sampleIndices)
        sampleIndices.dispose()
        flatTensor.dispose()

        // Compute num of bins
        numBins = numBins ?? histcounts(subTensor)

        // Compute bin width and scale values into bin indices
        const binWidth = tensorMax.sub(tensorMin).div(numBins)
        const binIndices = subTensor.sub(tensorMin).div(binWidth).floor().toInt()
        subTensor.dispose()

        const clampedIndices = binIndices.clipByValue(0, numBins - 1)
        binIndices.dispose()

        // Use tf.bincount for efficient histogram calculation
        const weights = tf.tensor([])
        const histogram = tf.bincount(clampedIndices, weights, numBins)
        clampedIndices.dispose()

        // Compute bin centers
        const binEdges = tf.linspace(tensorMin.arraySync(), tensorMax.arraySync(), numBins + 1)
        const binWidthScalar = binWidth.arraySync()
        const binCenters = binEdges.slice(1).sub(binWidthScalar / 2)

        // Compute the inverse cumulative mass function
        tensorMin.dispose()
        tensorMax.dispose()

        return [histogram, binCenters, binEdges]
    })
}

export function approximateDistribution(tensor, numBins, sampleRate) 
{
    return tf.tidy(() => 
    {
        let [hist, binCenters, binEdges] = approximateHistogram(tensor, numBins, sampleRate)

        // Normalize the histogram
        let totalCounts = hist.sum()
        let probabilityMassFunction = tf.div(hist, totalCounts)

        // Compute the cumulative mass function
        let cumulativeMassFunction = probabilityMassFunction.cumsum()

        // Compute the inverse cumulative mass function
        const [min, max] = [binEdges.min().arraySync(), binEdges.max().arraySync()]
        
        const t = normalize(binCenters, min, max).arraySync()
        const y = cumulativeMassFunction.arraySync()
        const x = binCenters.arraySync()

        let inverseCumulativeMassFunction = everpolate.linear(t, y, x).map((value) => Math.min(Math.max(value, min), max))
        inverseCumulativeMassFunction = tf.tensor(inverseCumulativeMassFunction)

        return {binCenters, probabilityMassFunction, cumulativeMassFunction, inverseCumulativeMassFunction}
    })
}

export function quantile(tensor, percentage)
{
    const array = tensor.reshape([-1])
    const k = Math.floor(array.size * (1 - percentage / 100))
    const topK = tf.topk(array, k, true) 
    array.dispose() 
    const quantile = topK.values.min() 
    topK.values.dispose() 
    topK.indices.dispose()
    return quantile
}

export function approximateQuantile(tensor, percentage, sampleRate)
{
    sampleRate = sampleRate ?? 0.01
    const array = tensor.reshape([-1])

    const sampleSize = Math.max(1, Math.floor(array.size * sampleRate))
    const indices = tf.randomUniform([sampleSize], 0, array.size, 'int32')
    const subArray = tf.gather(array, indices)
    array.dispose()

    const k = Math.floor(subArray.size * (1 - percentage / 100))
    const topK = tf.topk(subArray, k, true) 
    subArray.dispose() 
    const quantile = topK.values.min() 
    topK.values.dispose() 
    topK.indices.dispose()
    return quantile
}

export function approximateExtrema(tensor, sampleRate)
{
    return tf.tidy(() =>
    {
        sampleRate = sampleRate ?? 0.01
        const percentile = 99.9
    
        const array = tensor.reshape([-1])
        const sampleSize = Math.max(1, Math.floor(array.size * sampleRate))
        const indices = tf.randomUniform([sampleSize], 0, array.size, 'int32')
        const subArray = tf.gather(array, indices)
        array.dispose()
    
        const negArray = subArray.mul([-1])
        const k = Math.floor(subArray.size * (1 - percentile / 100))
    
        const topK = tf.topk(subArray, k, true) 
        const max = topK.values.min()   
        subArray.dispose()
    
        const botK = tf.topk(negArray, k, true) 
        const min = botK.values.min().mul([-1])
        negArray.dispose() 
         
        return [min, max]    
    })
}

export function resizeLinear(tensor, axis, newSize)
{
    tf.tidy(() => 
    {
        // interpolate between the two closest slices along axis
        const slices = []
        const size = tensor.shape[axis]

        for (let n = 0; n < newSize; n++) 
        {
            const newS   = (n + 0.5) / newSize  // Float index in range (0, 1)
            const s      = newS * size - 0.5    // Float index in range (0, size-1)
            const sFloor = Math.floor(s)        // Lower slice index
            const sCeil  = Math.ceil(s)         // Upper slice index
            const t      = s - sFloor           // Fractional part for interpolation

            const sliceFloor = slice(tensor, axis, sFloor)  // Slice at sFloor
            const sliceCeil  = slice(tensor, axis,  sCeil)  // Slice at sCeil
            const slice = mix(sliceFloor, sliceCeil, t)     // Slice interpolation
            sliceFloor.dispose()
            sliceCeil.dispose()
            slices.push(slice)
        }
        const resized = tf.concat(slices, axis)

        return resized       
    })
}

export function slice(tensor, axis, number)
{
    const begin = tensor.shape.map(() => 0)
    const size = tensor.shape.map((x) => x)
    begin[axis] = number
    size[axis] = 1
    return tensor.slice(begin, size)
}

export function mix(tensorA, tensorB, t)
{
    const scaledA = tensorA.mul([1 - t])
    const scaledB = tensorB.mul([t])
    const mixed = scaledA.add(scaledB)
    scaledA.dispose()
    scaledB.dispose()
    return mixed
}

export function normalize(tensor, min, max)
{
    return tf.tidy(() =>
    {
        const shifted = tensor.sub(min)
        const normalized = shifted.div(tf.sub(max, min))
        shifted.dispose()
        return normalized
    })
}

export function padCeil(tensor, divisions)
{
    const ceilDiv = (dimension) => Math.ceil(dimension / divisions)
    const padShape = tensor.shape.map(ceilDiv)
    const padded = tensor.pad(padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
    return padded
}

export function padCeilPow2(tensor)
{
    tf.tidy(() => 
    {
        const ceilPow2 = (x) => Math.pow(2, Math.ceil(Math.log2(x)))
        const padShape = tensor.shape.map(ceilPow2)
        const padded = tf.pad(tensor, padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
        return padded
    })
}

export function minPool3d(tensor, filterSize, strides, pad)
{
    return tf.tidy(() =>
    {
        const negative = tensor.mul([-1])
        const negMaxPool = tf.maxPool3d(negative, filterSize, strides, pad)
        negative.dispose()
        const tensorMinPool = negMaxPool.mul([-1])
        negMaxPool.dispose()
        return tensorMinPool
    })
} 

/**
 * Computes the occupancy map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the occupancy map is computed.
 * @param {number} division - The size of the pooling kernel in each dimension, determining the granularity of occupancy.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the occupancy values map.
 */
export function occupancyMap(tensor, threshold, division)
{
    return tf.tidy(() =>
    {
        const condition = tensor.greater(tf.scalar(threshold, 'float32'))
        const divisions = [division, division, division]

        const occupancymapTemp = tf.maxPool3d(condition, divisions, divisions, 'same')
        condition.dispose()
    
        const occupancyMap = occupancymapTemp.mul(tf.scalar(255, 'int32'))
        occupancymapTemp.dispose()
    
        return occupancyMap
    })
}

/**
 * Computes the multi resolution occupancy maps compacted inside an atlas for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the occupancy atlas is computed.
 * @param {number} division - The size of the pooling kernel in each dimension, determining the granularity of occupancy.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the occupancy values atlas.
 */
export function occupancyAtlas(tensor, threshold, division)
{
    return tf.tidy(() =>
    {
        const condition = tensor.greater(tf.scalar(threshold, 'float32'))
        const divisions = [division, division, division]

        const conditionPadded = padCeilPow2(condition)
        condition.dispose()

        const occupancymapTemp = tf.maxPool3d(conditionPadded, divisions, divisions, 'same')
        condition.dispose()
    
        let occupancyMap = occupancymapTemp.mul(tf.scalar(255, 'int32'))
        let occupancyatlas = occupancyMap.pad([[0, occupancyMap.shape[0] * 0.5], [0, 0], [0, 0], [0, 0] ])
        occupancymapTemp.dispose()

        const offsets = [occupancyMap.shape[0], 0, 0, 0]
        const numMaps = Math.floor(Math.log2(Math.min(...tensor.shape.slice(0, 3)))) + 1;

        for (let map = 1; map < numMaps; map++) 
        {
            const occupancymapTemp = tf.maxPool3d(occupancyMap, [2, 2, 2], [2, 2, 2], 'same')     
            const occupancymapPadded = occupancymapTemp.pad(offsets.map((offset, i) => [offset, occupancyatlas.shape[i] - offset - occupancyMap.shape[i]]))
            occupancymapTemp.dispose()
            
            occupancyMap.dispose()
            occupancyMap = occupancymapPadded
            const occupancyatlasTemp = occupancyatlas.add(occupancyMap)

            occupancyatlas.dispose()
            occupancyatlas = occupancyatlasTemp

            offsets[1] += occupancyMap.shape[1]
        }
        
        return [occupancyatlas, numMaps]
    })
}

/**
 * Computes the Chebyshev distance map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} occupancyMap - A occupancyMap representing the input data where the distance map is computed.
 * @param {number} spacing - The size of the pooling kernel in each dimension, determining the granularity of distance calculation.
 * @param {number} maxDistance - The maximum distance to compute for the distance map. 
 * @returns {tf.Tensor} - A tensor of the same shape as the input, containing the computed Chebyshev distance map.
 */
export function occupancyDistanceMap(tensor, threshold, division, maxDistance) 
{
    return tf.tidy(() => 
    {
        const occupancy = occupancyMap(tensor, threshold, division)

        let diffusionNext = occupancy.cast('bool')
        let diffusionPrev = tf.zeros(diffusionNext.shape, 'bool')
        let distanceMap = tf.zeros(diffusionNext.shape, 'int32')
    
        for (let iter = 0; iter <= maxDistance; iter++) 
        {
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distanceMapUpdate = diffusionUpdate.mul(tf.scalar(iter, 'int32'))
            diffusionUpdate.dispose()
            
            const distanceMapTemp = distanceMap.add(distanceMapUpdate);
            distanceMapUpdate.dispose()
    
            distanceMap.dispose()
            distanceMap = distanceMapTemp
    
            diffusionPrev.dispose() 
            diffusionPrev = diffusionNext
            diffusionNext = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
        }
        
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        const distanceMapUpdate = diffusionUpdate.mul(tf.scalar(maxDistance, 'int32'))
        diffusionUpdate.dispose()
    
        const distanceMapTemp = distanceMap.add(distanceMapUpdate);
        distanceMapUpdate.dispose()
    
        distanceMap.dispose()
        distanceMap = distanceMapTemp
    
        diffusionNext.dispose()
        diffusionPrev.dispose()
    
        return distanceMap
    })
}

/**
 * Computes the extrema map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the extrema map is computed.
 * @param {number} division - The size of the pooling kernel in each dimension, determining the granularity of the map.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the extrema values map.
 */
export function extremaMap(tensor, division)
{
    return tf.tidy(() =>
    {
        const divisions = [division, division, division]
        const minimaMap = minPool3d(tensor, divisions, divisions, 'same')
        const maximaMap = tf.maxPool3d(tensor, divisions, divisions, 'same')
        const extremaMap = tf.concat([minimaMap, maximaMap], 3)            
        return extremaMap
    })
}

/**
 * Computes the Chebyshev distance map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} occupancyMap - A occupancyMap representing the input data where the distance map is computed.
 * @param {number} spacing - The size of the pooling kernel in each dimension, determining the granularity of distance calculation.
 * @param {number} maxDistance - The maximum distance to compute for the distance map. 
 * @returns {tf.Tensor} - A tensor of the same shape as the input, containing the computed Chebyshev distance map.
 */
export function extremaDistanceMap(tensor, division, maxDistance) 
{
    return tf.tidy(() => 
    {
        let [minimaMap, maximaMap] = tf.unstack(extremaMap(tensor, division), 3) 
        let distanceMap = tf.zeros(minimaMap.shape, 'int32')
    
        for (let iter = 0; iter <= maxDistance; iter++) 
        {
            const conditionUpdate = tf.greaterEqual(minimaMap, maximaMap)
            const distanceMapUpdate = conditionUpdate.mul(tf.scalar(iter, 'int32'))
            conditionUpdate.dispose()
            
            const distanceMapTemp = tf.maximum(distanceMap, distanceMapUpdate);
            distanceMapUpdate.dispose()
            distanceMap.dispose()
            distanceMap = distanceMapTemp
    
            const maximaMapTemp = tf.maxPool3d(maximaMap, [3, 3, 3], [1, 1, 1], 'same')
            maximaMap.dispose()
            maximaMap = maximaMapTemp
        }
        
        minimaMap.dispose()
        maximaMap.dispose()
    
        return distanceMap
    })
}

export function separableConv3d(tensor, filters)
{
    const passX = tf.conv3d(tensor, filters.separableX, 1, 'same')
    const passY = tf.conv3d(passX, filters.separableY, 1, 'same') 
    passX.dispose()
    const passZ = tf.conv3d(passY, filters.separableZ, 1, 'same') 
    passY.dispose()
    return passZ
}

export function gradients3d(tensor, spacing)
{
    return tf.tidy(() => 
    {
        const kernel = scharrKernel()

        const compute = (filter, space) => 
        {
            const convolution = separableConv3d(tensor, filter)
            const gradient = convolution.div([space])
            convolution.dispose() 
            return gradient
        }

        const gradientsX = compute(kernel.x, spacing.x)
        const gradientsY = compute(kernel.y, spacing.y)
        const gradientsZ = compute(kernel.z, spacing.z)
        const gradients = tf.concat([gradientsX, gradientsY, gradientsZ], 3)

        return gradients
    })   
}

export function smoothing3d(tensor, spacing)
{
    return tf.tidy(() => 
    {
        const compute = (filter, space) => 
        {
            const convolution = separableConv3d(tensor, filter)
            const gradient = convolution.div([space])
            convolution.dispose() 
            return gradient
        }

        const gradientsX = compute(scharrKernel.x, spacing.x)
        const gradientsY = compute(scharrKernel.y, spacing.y)
        const gradientsZ = compute(scharrKernel.z, spacing.z)
        const gradients = tf.concat([gradientsX, gradientsY, gradientsZ], 3)

        return gradients
    })   
}

/* Sources :
    // https://homepages.inf.ed.ac.uk/rbf/HIPR2/gsmooth.htm
    // https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel
    // https://www.youtube.com/watch?v=SiJpkucGa1o&t=416s&ab_channel=Computerphile
*/
export function gaussianKernel(radius)
{
    return tf.tidy(() =>
    {
        const length = radius * 2 + 1
        const sigma = radius / 3
        const variance = sigma ** 2
        const generator = (n) => Math.exp(-(n ** 2) / (2 * variance)) / Math.sqrt(2 * Math.PI * variance)

        const coeffsHalf = Array.from({ length: radius + 1 }, (_, n) => generator(n))
        const coeffs = [...coeffsHalf.slice(1).reverse(), ...coeffsHalf]
        const coeffSum = coeffs.reduce((sum, value) => sum + value, 0)
        const coeffsNorm = coeffs.map((coeff) => coeff / coeffSum)

        const kernel = {
            separableX: tf.tensor5d(coeffsNorm, [1, 1, length, 1, 1], 'float32'),
            separableY: tf.tensor5d(coeffsNorm, [1, length, 1, 1, 1], 'float32'),
            separableZ: tf.tensor5d(coeffsNorm, [length, 1, 1, 1, 1], 'float32'),
        }

        return kernel
    })
}

/* Sources :
    // https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel
    // https://www.youtube.com/watch?v=SiJpkucGa1o&t=416s&ab_channel=Computerphile
*/
export function besselKernel(radius)
{
    return tf.tidy(() =>
    {
        const length = radius * 2 + 1
        const sigma = radius / 3
        const variance = sigma ** 2
        const generator = (n) => Math.exp(variance) * BESSEL.besseli(this.variance, n)

        const coeffsHalf = Array.from({ length: radius + 1 }, (_, n) => generator(n))
        const coeffs = [...coeffsHalf.slice(1).reverse(), ...coeffsHalf]
        const coeffSum = coeffs.reduce((sum, value) => sum + value, 0)
        const coeffsNorm = coeffs.map((coeff) => coeff / coeffSum)

        const kernel = {
            separableX: tf.tensor5d(coeffsNorm, [1, 1, length, 1, 1], 'float32'),
            separableY: tf.tensor5d(coeffsNorm, [1, length, 1, 1, 1], 'float32'),
            separableZ: tf.tensor5d(coeffsNorm, [length, 1, 1, 1, 1], 'float32'),
        }

        return kernel
    })
}

export function averageKernel()
{
    return tf.tidy(() =>
    {
        const length = radius * 2 + 1
        const generator = (n) => 1 

        const coeffsHalf = Array.from({ length: radius + 1 }, (_, n) => generator(n))
        const coeffs = [...coeffsHalf.slice(1).reverse(), ...coeffsHalf]
        const coeffSum = coeffs.reduce((sum, value) => sum + value, 0)
        const coeffsNorm = coeffs.map((coeff) => coeff / coeffSum)

        const kernel = {
            separableX: tf.tensor5d(coeffsNorm, [1, 1, length, 1, 1], 'float32'),
            separableY: tf.tensor5d(coeffsNorm, [1, length, 1, 1, 1], 'float32'),
            separableZ: tf.tensor5d(coeffsNorm, [length, 1, 1, 1, 1], 'float32'),
        }

        return kernel
    })
}

/* Sources
    https://www.wikiwand.com/en/articles/Sobel_operator
*/
export function scharrKernel()
{
    return tf.tidy(() => 
    { 
        const kernel = {
            x : {
                separableX: tf.tensor5d([-1,  0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                separableY: tf.tensor5d([ 3, 10, 3], [1, 3, 1, 1, 1], 'float32').div([16]),
                separableZ: tf.tensor5d([ 3, 10, 3], [3, 1, 1, 1, 1], 'float32').div([16]),
            },
            y : {
                separableX: tf.tensor5d([ 3, 10, 3], [1, 1, 3, 1, 1], 'float32').div([16]),
                separableY: tf.tensor5d([-1,  0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                separableZ: tf.tensor5d([ 3, 10, 3], [3, 1, 1, 1, 1], 'float32').div([16]),
            },
            z : {
                separableX: tf.tensor5d([ 3, 10, 3], [1, 1, 3, 1, 1], 'float32').div([16]),
                separableY: tf.tensor5d([ 3, 10, 3], [1, 3, 1, 1, 1], 'float32').div([16]),
                separableZ: tf.tensor5d([-1,  0, 1], [3, 1, 1, 1, 1], 'float32').div([2]),
            },
        }
        return kernel
    })
}

/* Sources
    https://www.wikiwand.com/en/articles/Sobel_operator
*/
export function sobelKernel()
{
    return tf.tidy(() => 
    { 
        const kernel = {
            x : {
                separableX: tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                separableY: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                separableZ: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
            },
            y : {
                separableX: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([4]),
                separableY: tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                separableZ: tf.tensor5d([ 1, 2, 1], [3, 1, 1, 1, 1], 'float32').div([4]),
            },
            z : {
                separableX: tf.tensor5d([ 1, 2, 1], [1, 1, 3, 1, 1], 'float32').div([4]),
                separableY: tf.tensor5d([ 1, 2, 1], [1, 3, 1, 1, 1], 'float32').div([4]),
                separableZ: tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2]),
            },
        }
        return kernel
    })
}

export function prewittKernel()
{
    return tf.tidy(() => 
    { 
        const kernel = {
            x : {
                separableX: tf.tensor5d([-1, 0, 1], [1, 1, 3, 1, 1], 'float32').div([2]),
                separableY: tf.tensor5d([ 1, 1, 1], [1, 3, 1, 1, 1], 'float32').div([3]),
                separableZ: tf.tensor5d([ 1, 1, 1], [3, 1, 1, 1, 1], 'float32').div([3]),
            },
            y : {
                separableX: tf.tensor5d([ 1, 1, 1], [1, 1, 3, 1, 1], 'float32').div([3]),
                separableY: tf.tensor5d([-1, 0, 1], [1, 3, 1, 1, 1], 'float32').div([2]),
                separableZ: tf.tensor5d([ 1, 1, 1], [3, 1, 1, 1, 1], 'float32').div([3]),
            },
            z : {
                separableX: tf.tensor5d([ 1, 1, 1], [1, 1, 3, 1, 1], 'float32').div([3]),
                separableY: tf.tensor5d([ 1, 1, 1], [1, 3, 1, 1, 1], 'float32').div([3]),
                separableZ: tf.tensor5d([-1, 0, 1], [3, 1, 1, 1, 1], 'float32').div([2]),
            },

        }
        return kernel
    })
}
