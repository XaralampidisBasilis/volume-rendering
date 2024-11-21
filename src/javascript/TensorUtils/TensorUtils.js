import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs';

export function histogram(tensor, numBins) 
{
    return tf.tidy(() => 
    {
        const flatTensor = tensor.flatten()

        // Compute the min and max values of the tensor
        const tensorMin = flatTensor.min()
        const tensorMax = flatTensor.max()

        // Compute bin edges and width
        const binEdges = tf.linspace(tensorMin, tensorMax, numBins + 1)
        const binWidth = tensorMax.sub(tensorMin).div(numBins)

        // Calculate bin indices for each element
        const indices = flatTensor.sub(tensorMin).div(binWidth).floor().toInt()
        flatTensor.dispose()

        const clampedIndices = indices.clipByValue(0, numBins - 1)
        indices.dispose()

        // Compute histogram using tf.oneHot and tf.sum
        const oneHotBins = tf.oneHot(clampedIndices, numBins)
        clampedIndices.dispose()
        
        const histogramCounts = oneHotBins.sum(0)
        oneHotBins.dispose()

        // Normalize the histogram so that the sum of counts equals 1
        const totalCounts = histogramCounts.sum()
        const histogram = histogramCounts.div(totalCounts)
        histogramCounts.dispose()

        // Clean up intermediate tensors
        tensorMin.dispose()
        tensorMax.dispose()
        binWidth.dispose()
        totalCounts.dispose()

        return [histogram, binEdges]
    })
}

export function histcounts(flatTensor, tensorMin, tensorMax)
{
    // Compute Interquartile Range (IQR)
    const q75 = flatTensor.quantile(0.75);
    const q25 = flatTensor.quantile(0.25);
    const IQR = q75.sub(q25);

    // Number of data points
    const N = flatTensor.size;

    // Compute bin width using Freedman-Diaconis Rule
    const binWidth = IQR.mul(2).div(tf.scalar(Math.cbrt(N)));

    // Compute number of bins
    // Avoid division by zero in case IQR is zero
    const range = tensorMax.sub(tensorMin);
    const numBinsComputed = tf.where(
        binWidth.gt(0),
        range.div(binWidth).ceil(),
        tf.scalar(10) // Default to 10 bins if IQR is zero
    ).clipByValue(1, 1000).dataSync()[0]; // Limit to reasonable number of bins

    const numBins = Math.round(numBinsComputed);
    
    return Math.round(numBinsComputed);
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

export function range(tensor) { return [tensor.min(), tensor.max()] }

export function rangeRobust(tensor)
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

export function rangeRobustFast(tensor)
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