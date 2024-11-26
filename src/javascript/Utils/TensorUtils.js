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

        // Subsample the tensor
        const sampleRate = 0.01
        const sampleSize = Math.max(1, Math.floor(flatTensor.size * sampleRate))
        const sampleIndices = tf.randomUniform([sampleSize], 0, flatTensor.size, 'int32')
        const subTensor = tf.gather(flatTensor, sampleIndices)
        sampleIndices.dispose()
        flatTensor.dispose()

        // Compute bin width and scale values into bin indices
        const binWidth = tensorMax.sub(tensorMin).div(numBins)
        const binIndices = subTensor.sub(tensorMin).div(binWidth).floor().toInt()
        const clampedIndices = binIndices.clipByValue(0, numBins - 1)
        subTensor.dispose()

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

        return [histogram, binCenters, binIndices]
    })
}

export function histcounts(tensor)
{
    return tf.tidy(() =>
    { 
        // compute interquartile range (IQR)
        const q25 = quantile(tensor, 0.25)
        const q75 = quantile(tensor, 0.75)
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

export function distribution(tensor, numBins) 
{
    let [histogram, binCenters, binIndices] = histogram(tensor, numBins)

    return tf.tidy(() => 
    {
        // Normalize the histogram
        let totalCounts = histogram.sum()
        let probabilityMassFunction = tf.div(histogram, totalCounts)

        // Compute the cumulative mass function
        let cumulativeMassFunction = probabilityMassFunction.cumsum()

       // Compute the inverse cumulative mass function
        let clamp = (min, max) => value => Math.max(Math.min(value, max), min)
        let inverseCumulativeMassFunction = everpolate
            .linear(binCenters.arraySync(), cumulativeMassFunction.arraySync(), binCenters.arraySync())
            .map(clamp(0.0, 1.0))
        inverseCumulativeMassFunction = tf.tensor(inverseCumulativeMassFunction)

        return {binCenters, binIndices, probabilityMassFunction, cumulativeMassFunction, inverseCumulativeMassFunction}
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

export function extrema(tensor)
{
    return tf.tidy(() =>
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
    const shifted = tensor.sub(min)
    const normalized = shifted.div(tf.sub(max, min))
    shifted.dispose()
    return normalized
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
    const ceilPow2 = (x) => Math.pow(2, Math.ceil(Math.log2(x)))
    const padShape = tensor.shape.map(ceilPow2)
    const padded = tf.pad(tensor, padShape.map((dim, i) => [0, dim - tensor.shape[i]]))
    tensor.dispose()
    return padded
}

/**
 * Computes the occupancy map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the occupancy map is computed.
 * @param {number} spacing - The size of the pooling kernel in each dimension, determining the granularity of occupancy.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the occupancy values map.
 */
export function occupancymap(tensor, spacing)
{
    return tf.tidy(() =>
    {
        const spacings = [spacing, spacing, spacing]
        const condition = tensor.greater([0])
    
        const occupancymapTemp = tf.maxPool3d(condition, spacings, spacings, 'same')
        condition.dispose()
    
        const occupancymap = occupancymapTemp.mul([255])
        occupancymapTemp.dispose()
    
        return occupancymap
    })
}

/**
 * Computes the multi resolution occupancy maps compacted inside an atlas for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the occupancy atlas is computed.
 * @param {number} spacing - The size of the pooling kernel in each dimension, determining the granularity of occupancy.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the occupancy values atlas.
 */
export function occupancyatlas(tensor, spacing)
{
    return tf.tidy(() =>
    {
        const spacings = [spacing, spacing, spacing]
        const condition = tensor.greater([0])
    
        const conditionPadded = padCeilPow2(condition)
        condition.dispose()

        const occupancymapTemp = tf.maxPool3d(conditionPadded, spacings, spacings, 'same')
        condition.dispose()
    
        let occupancymap = occupancymapTemp.mul([255])
        let occupancyatlas = occupancymap.pad([[0, occupancymap.shape[0] * 0.5], [0, 0], [0, 0], [0, 0] ])
        occupancymapTemp.dispose()

        const offsets = [occupancymap.shape[0], 0, 0, 0]
        const numMaps = Math.floor(Math.log2(Math.min(...tensor.shape.slice(0, 3)))) + 1;

        for (let map = 1; map < numMaps; map++) 
        {
            const occupancymapTemp = tf.maxPool3d(occupancymap, [2, 2, 2], [2, 2, 2], 'same')     
            const occupancymapPadded = occupancymapTemp.pad(offsets.map((offset, i) => [offset, occupancyatlas.shape[i] - offset - occupancymap.shape[i]]))
            occupancymapTemp.dispose()
            
            occupancymap.dispose()
            occupancymap = occupancymapPadded
            const occupancyatlasTemp = occupancyatlas.add(occupancymap)

            occupancyatlas.dispose()
            occupancyatlas = occupancyatlasTemp

            offsets[1] += occupancymap.shape[1]
        }
        
        return [occupancyatlas, numMaps]
    })
}

/**
 * Computes the Chebyshev distance map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} occupancymap - A occupancymap representing the input data where the distance map is computed.
 * @param {number} spacing - The size of the pooling kernel in each dimension, determining the granularity of distance calculation.
 * @param {number} maxDistance - The maximum distance to compute for the distance map. 
 * @returns {tf.Tensor} - A tensor of the same shape as the input, containing the computed Chebyshev distance map.
 */
export function distancemap(occupancymap, maxDistance) 
{
    return tf.tidy(() => 
    {
        let diffusionNext = occupancymap.clone()
        let diffusionPrev = tf.zerosLike(diffusionNext, 'bool')
        let distancemap = tf.zerosLike(diffusionNext, 'int32')
        condition.dispose() 
    
        for (let iter = 0; iter < maxDistance; iter++) 
        {
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distancemapUpdate = diffusionUpdate.mul([iter])
            diffusionUpdate.dispose()
            
            const distancemapTemp = distancemap.add(distancemapUpdate);
            distancemapUpdate.dispose()
    
            distancemap.dispose()
            distancemap = distancemapTemp
    
            diffusionPrev.dispose() 
            diffusionPrev = diffusionNext
            diffusionNext = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
        }
        
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        const distancemapUpdate = diffusionUpdate.mul([maxDistance])
        diffusionUpdate.dispose()
    
        const distancemapTemp = distancemap.add(distancemapUpdate);
        distancemapUpdate.dispose()
    
        distancemap.dispose()
        distancemap = distancemapTemp
    
        diffusionNext.dispose()
        diffusionPrev.dispose()
    
        return distancemap
    })
}
