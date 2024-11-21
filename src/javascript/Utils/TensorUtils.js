import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import everpolate from 'everpolate'

export function histogram(tensor, numBins) 
{
    return tf.tidy(() => 
    {
        const flatTensor = tensor.flatten()

        // Compute the min and max values of the tensor
        const tensorMin = flatTensor.min()
        const tensorMax = flatTensor.max()

        // Compute bin width and scale values into bin indices
        const binWidth = tensorMax.sub(tensorMin).div(numBins)
        const indices = flatTensor.sub(tensorMin).div(binWidth).floor().toInt()
        const clampedIndices = indices.clipByValue(0, numBins - 1)

        flatTensor.dispose()
        indices.dispose()

        // Use tf.bincount for efficient histogram calculation
        const weights = tf.tensor([])
        const histogramCounts = tf.bincount(clampedIndices, weights, numBins)
        clampedIndices.dispose()

        // Normalize the histogram
        const totalCounts = histogramCounts.sum()
        const pmf = tf.div(histogramCounts, totalCounts)
        const cmf = pmf.cumsum()

        histogramCounts.dispose()
        totalCounts.dispose()

        // Compute bin centers
        const binEdges = tf.linspace(tensorMin.arraySync(), tensorMax.arraySync(), numBins + 1)
        const binWidthScalar = binWidth.arraySync()
        const binCenters = binEdges.slice(1).sub(binWidthScalar / 2)
        binEdges.dispose()

        tensorMin.dispose()
        tensorMax.dispose()
        binWidth.dispose()

        return { PMF: pmf, CMF: cmf, binCenters: binCenters }
    });
}

export function histogramFast(tensor, numBins) 
{
    return tf.tidy(() => 
    {
        const flatTensor = tensor.flatten()

        // Subsample the tensor
        const sampleRate = 0.01
        const sampleSize = Math.max(1, Math.floor(flatTensor.size * sampleRate))
        const sampleIndices = tf.randomUniform([sampleSize], 0, flatTensor.size, 'int32')
        const subTensor = tf.gather(flatTensor, sampleIndices)

        sampleIndices.dispose()
        flatTensor.dispose()

        // Compute the min and max values of the tensor
        const tensorMin = subTensor.min()
        const tensorMax = subTensor.max()

        // Compute bin width and scale values into bin indices
        const binWidth = tensorMax.sub(tensorMin).div(numBins)
        const indices = subTensor.sub(tensorMin).div(binWidth).floor().toInt()
        const clampedIndices = indices.clipByValue(0, numBins - 1)

        subTensor.dispose()
        indices.dispose()

        // Use tf.bincount for efficient histogram calculation
        const weights = tf.tensor([])
        const histogram = tf.bincount(clampedIndices, weights, numBins)
        clampedIndices.dispose()

        // Compute bin centers
        const binEdges = tf.linspace(tensorMin.arraySync(), tensorMax.arraySync(), numBins + 1)
        const binWidthScalar = binWidth.arraySync()
        const binCenters = binEdges.slice(1).sub(binWidthScalar / 2)
        binEdges.dispose()

        // Compute the inverse cumulative mass function
        tensorMin.dispose()
        tensorMax.dispose()
        binWidth.dispose()

        return [histogram, binCenters]
    })
}

export function histcounts(flatTensor, tensorMin, tensorMax)
{
    // Compute Interquartile Range (IQR)
    const q25 = quantile(flatTensor, 0.25)
    const q75 = quantile(flatTensor, 0.75)
    const IQR = q75.sub(q25)

    // Number of data points
    const N = flatTensor.size

    // Compute bin width using Freedman-Diaconis Rule
    const binWidth = IQR.mul(2).div(tf.scalar(Math.cbrt(N)))

    // Compute number of bins
    // Avoid division by zero in case IQR is zero, and default to 10
    const range = tensorMax.sub(tensorMin)
    const numBinsComputed = tf.where(binWidth.greater(0), range.div(binWidth).ceil(), tf.scalar(10))

    const numBins = Math.round(numBinsComputed.clipByValue(1, 1000).dataSync()[0]) // Limit to reasonable number of bins
    
    return numBins
}

export function distribution(tensor, numBins) 
{
    const [histogram, binCenters] = histogramFast(tensor, numBins)

    // Normalize the histogram
    const totalCounts = histogram.sum()
    const pmf = tf.div(histogram, totalCounts)
    histogram.dispose()
    totalCounts.dispose()

    // Compute the inverse cumulative mass function
    const cmf = pmf.cumsum()

    // array sync
    const x = binCenters.arraySync()
    const f = pmf.arraySync()
    const F = cmf.arraySync()

    const clamp = (min, max) => value => Math.max(Math.min(value, max), min)
    const Finv = everpolate.linear(x, F, x).map(clamp(0.0, 1.0))

    return {x, f, F, Finv}
}


export function quantile(tensor, percentage)
{
    const array = tensor.reshape([-1])
    const k = Math.floor(array.size * (1 - percentage / 100))
    const topK = tf.topk(array, k, true) 
    array.dispose() 
    const percentile = topK.values.min() 
    topK.values.dispose() 
    topK.indices.dispose()
    return percentile
}

export function extrema(tensor) 
{
    return [tensor.min(), tensor.max()] 
}

export function extremaRobust(tensor)
{
    const percentile = 99.9

    const arrayMax = tensor.reshape([-1])
    const arrayMin = arrayMax.mul([-1])
    const k = Math.floor(arrayMax.size * (1 - percentile / 100))

    const maxK = tf.topk(arrayMax, k, true) 
    const max = maxK.values.min()
    maxK.values.dispose() 
    maxK.indices.dispose()
    arrayMax.dispose()

    const minK = tf.topk(arrayMin, k, true) 
    const min = minK.values.min().mul([-1])
    minK.values.dispose() 
    minK.indices.dispose()
    arrayMin.dispose() 

    return [min, max]    
}

export function extremaRobustFast(tensor)
{
    const percentile = 99.9
    const sampleRate = 0.01

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

    tf.dispose([botK, topK]) 
 
    return [min, max]    
}

export function resizeLinear(tensor, axis, newSize)
{
    const size = tensor.shape[axis]
    if (size <= newSize)
         return tensor.clone()     

    // Interpolate between the two closest slices along Z for each voxel
    const slices = []
    for (let n = 0; n < newSize; n++) 
    {
        const newS   = (n + 0.5) / newSize  // Float index in range (0, 1)
        const s      = newS * size - 0.5    // Float index in range (0, size-1)
        const sFloor = Math.floor(s)        // Lower slice index
        const sCeil  = Math.ceil(s)         // Upper slice index
        const t      = s - sFloor           // Fractional part for interpolation
    
        const sliceFloor = this.slice(tensor, axis, sFloor)  // Slice at sFloor
        const sliceCeil  = this.slice(tensor, axis,  sCeil)  // Slice at sCeil
        const slice = this.mix(sliceFloor, sliceCeil, t)     // Slice interpolation
        sliceFloor.dispose()
        sliceCeil.dispose()
        slices.push(slice)
    }

    tensor.dispose()
    const resized = tf.concat(slices, axis)
    tf.dispose(slices)
    return resized       
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
