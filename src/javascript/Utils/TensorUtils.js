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
        const t = normalize3d(binEdges).arraySync()
        const y = cumulativeMassFunction.arraySync()
        const x = binEdges.arraySync()

        let inverseCumulativeMassFunction = everpolate.linear(t, y, x)
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

// export function resizeLinear(tensor, axis, newSize)
// {
//     return tf.tidy(() => 
//     {
//         // interpolate between the two closest slices along axis
//         const slices = []
//         const size = tensor.shape[axis]

//         for (let n = 0; n < newSize; n++) 
//         {
//             const newS   = (n + 0.5) / newSize  // Float index in range (0, 1)
//             const s      = newS * size - 0.5    // Float index in range (0, size-1)
//             const sFloor = Math.floor(s)        // Lower slice index
//             const sCeil  = Math.ceil(s)         // Upper slice index
//             const t      = s - sFloor           // Fractional part for interpolation

//             const sliceFloor = slice(tensor, axis, sFloor)  // Slice at sFloor
//             const sliceCeil  = slice(tensor, axis,  sCeil)  // Slice at sCeil
//             const sliceT = mix(sliceFloor, sliceCeil, t)     // Slice interpolation
//             sliceFloor.dispose()
//             sliceCeil.dispose()
//             slices.push(sliceT)
//         }
//         const resized = tf.concat(slices, axis)

//         return resized       
//     })
// }

export function resizeLinear(tensor, axis, newSize) 
{
    return tf.tidy(() => 
    {
        const size = tensor.shape[axis]

        // Compute indices for interpolation
        const newS = tf.linspace(0.5 / newSize, 1 - 0.5 / newSize, newSize) // Normalized indices
        const s = newS.mul(size).sub(0.5)                                   // Scale to tensor's axis range
        const sFloor = tf.clipByValue(tf.floor(s).toInt(), 0, size - 1)     // Lower indices, clipped
        const sCeil = tf.clipByValue(tf.ceil(s).toInt(), 0, size - 1)       // Upper indices, clipped

        // Gather slices for sFloor and sCeil along the specified axis
        const expandedFloor = tf.gather(tensor, sFloor, axis)
        const expandedCeil = tf.gather(tensor, sCeil, axis)

        // Compute interpolation weights
        const t = s.sub(tf.floor(s)) // Fractional part for interpolation
        const tShape = new Array(tensor.shape.length).fill(1)
        tShape[axis] = t.size // Match dimensions along the interpolation axis
        const tExpanded = tf.reshape(t, tShape) // Reshape for broadcasting

        // Perform linear interpolation
        const interpolated = expandedFloor.mul(tf.sub(1, tExpanded)).add(expandedCeil.mul(tExpanded))

        return interpolated
    })
}

export function boundingInterval(occupancy, axis) 
{
    return tf.tidy(() => 
    {
        // Check input is boolean
        if (occupancy.dtype !== "bool") {
            throw new Error('Input tensor must be of type bool');
        }
        
        // Scalar tensors
        const scalarOne = tf.scalar(1, 'int32')

        // Create a list of all axes and remove the target axis
        const axes = [...Array(occupancy.rank).keys()].filter((x) => x !== axis)
        
        // Compute the collapsed view along the specified axis
        const collapsed = occupancy.any(axes) 
        
        // Find the first non-zero index (minInd)
        const minIndTemp = collapsed.argMax(0) // First True from the left
        
        // Find the last non-zero index (maxInd)
        const reversed = collapsed.reverse()
        const maxIndTemp = tf.sub(occupancy.shape[axis], reversed.argMax()).sub(scalarOne) // First True from the right
        
        // Check if there are any true values in the collapsed tensor
        const isNonSingular = tf.any(collapsed)

        // If collapsed is singular return zero indices
        const minInd = minIndTemp.mul(isNonSingular) // min indices are included 
        const maxInd = maxIndTemp.mul(isNonSingular) // max indices are included 

        // Return the bounds
        return [minInd, maxInd] 
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

export function mix(A, B, t)
{
    const scaledA = A.mul([1 - t])
    const scaledB = B.mul([t])
    const mixed = scaledA.add(scaledB)
    scaledA.dispose()
    scaledB.dispose()
    return mixed
}

export function shift(tensor, axes, shifts) 
{
    return tf.tidy(() => 
    {
        let shiftedTensor = tensor.clone()

        // Iterate through each axis and perform the shift
        for (let i = 0; i < axes.length; i++) 
        {
            const axis = axes[i]
            const shift = shifts[i]
            const shape = shiftedTensor.shape
            const size = shape[axis]
            const shiftAbs = Math.abs(shift)

            let shiftedPart, repeatedPart, lastSlice, firstSlice, shiftedTensorTemp

            if (shift > 0) 
            {
                // Positive shift (right/down)
                shiftedPart = tf.slice(
                    shiftedTensor,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? shiftAbs : 0)),
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? size - shiftAbs : shape[j]))
                )

                lastSlice = tf.slice(
                    shiftedTensor,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? size - 1 : 0)),
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? 1 : shape[j]))
                )

                repeatedPart = tf.tile(
                    lastSlice,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? shiftAbs : 1))
                )

                shiftedTensorTemp = tf.concat([repeatedPart, shiftedPart], axis)

                // Dispose intermediate tensors
                tf.dispose([shiftedPart, lastSlice, repeatedPart])
            } 
            else 
            {
                // Negative shift (left/up)
                shiftedPart = tf.slice(
                    shiftedTensor,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? 0 : 0)),
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? size - shiftAbs : shape[j]))
                )

                firstSlice = tf.slice(
                    shiftedTensor,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? 0 : 0)),
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? 1 : shape[j]))
                )

                repeatedPart = tf.tile(
                    firstSlice,
                    Array.from({ length: shiftedTensor.rank }, (dim, j) => (j === axis ? shiftAbs : 1))
                )

                shiftedTensorTemp = tf.concat([shiftedPart, repeatedPart], axis)

                // Dispose intermediate tensors
                tf.dispose([shiftedPart, firstSlice, repeatedPart])
            }

            shiftedTensor.dispose()
            shiftedTensor = shiftedTensorTemp
        }

        return shiftedTensor
    })
}

export function padCeil(tensor, divisions, constantValue = 0)
{
    return tf.tidy(() => 
    {
        const ceilDiv = (dimension) => Math.ceil(dimension / divisions)
        const padShape = tensor.shape.map(ceilDiv)
        const padded = tensor.pad(padShape.map((dim, i) => [0, dim - tensor.shape[i]]), constantValue)
        return padded
    })
}

export function padCeilPow2(tensor)
{
    return tf.tidy(() => 
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
        const scalarNegativeOne = tf.scalar(-1, 'float32')
        const negative = tensor.mul(scalarNegativeOne)
        const negMaxPool = tf.maxPool3d(negative, filterSize, strides, pad)
        negative.dispose()
        const tensorMinPool = negMaxPool.mul(scalarNegativeOne)
        negMaxPool.dispose()
        return tensorMinPool
    })
} 

export function separableConv3d(tensor, filters, strides = 1, pad = 'same')
{
    return tf.tidy(() => 
    {
        const passX = tf.conv3d(tensor, filters.separableX, strides, pad)
        const passY = tf.conv3d(passX, filters.separableY, strides, pad) 
        passX.dispose()
        const passZ = tf.conv3d(passY, filters.separableZ, strides, pad) 
        passY.dispose()
        return passZ
    })
}

export function gradients3d(tensor, spacing)
{
    return tf.tidy(() => 
    {
        const kernel = scharrKernel()

        const compute = (filter, space) => 
        {
            const result = separableConv3d(tensor, filter)
            const gradient = result.div([space])
            result.dispose() 
            return gradient
        }

        const gradientsX = compute(kernel.x, spacing.x)
        const gradientsY = compute(kernel.y, spacing.y)
        const gradientsZ = compute(kernel.z, spacing.z)

        const gradients = tf.concat([gradientsX, gradientsY, gradientsZ], 3)

        return gradients
    })   
}

export function smooth3d(tensor, radius)
{
    return tf.tidy(() => 
    {
        const kernel = besselKernel(radius)
        const smoothed = separableConv3d(tensor, kernel)

        return smoothed
    }) 
}

export function normalize3d(tensor)
{
    return tf.tidy(() =>
    {
        const minValue = tensor.min([0, 1, 2])
        const maxValue = tensor.max([0, 1, 2])
        const range = tf.sub(maxValue, minValue)
        const shifted = tensor.sub(minValue)
        const normalized = shifted.div(range)
        shifted.dispose()
        const minArray = minValue.arraySync()
        const maxArray = maxValue.arraySync()      
        return [normalized, minArray, maxArray]
    })
}

export function quantize3d(tensor, levels = 256) 
{
    return tf.tidy(() => 
        {
        // Normalize the tensor to [0, 1] range
        const [normalized, min, max] = normalize3d(tensor)

        // Scale to the specified quantization levels
        const scaled = normalized.mul(tf.scalar(levels - 1))
        normalized.dispose()

        // Clip values to the range [0, levels]
        const clipped = scaled.clipByValue(0, levels - 1)
        scaled.dispose()

        // Round and cast to integer type
        const rounded = clipped.round()
        clipped.dispose()
        const quantized = rounded.cast('int32')
        rounded.dispose()

        // Return the quantized tensor, along with the original min and max
        return [quantized, min, max]
    })
}

export function downscale3d(tensor, scale)
{
    return tf.tidy(() => 
    {
        if (scale < 1) throw new Error(`TensorUtils.downscale3d: scale must be greater than 1`)

        const newShape = tensor.shape.map((dimension) => Math.ceil(dimension / scale))
        const downscale1 = resizeLinear(tensor,     0, newShape[0])
        const downscale2 = resizeLinear(downscale1, 1, newShape[1])
        const downscale3 = resizeLinear(downscale2, 2, newShape[2])
        return downscale3
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
        const generator = (n) => Math.exp(variance) * BESSEL.besseli(variance, n)

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


export function densityOccupancyMap(tensor4d, threshold, subDivision)
{
    return tf.tidy(() =>
    {
        // Scalars for threshold and output scaling
        const scalarThreshold = tf.scalar(threshold, 'float32')
        const scalar255 = tf.scalar(255, 'int32')
    
        // Compute occupied regions greater than threshold
        const occupied = tensor4d.greater(scalarThreshold)

        // If no subdivision is needed, scale and return
        if (subDivision === 1) {
            return occupied.mul(scalar255)
        }

        // Calculate necessary padding for valid subdivisions
        const padAmounts = occupied.shape.map((dim, i) => {
            const paddedDim = i < 3 ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
            return [0, paddedDim - dim]
        })

        // Apply padding
        const occupiedPadded = tf.pad(occupied, padAmounts)
        occupied.dispose()

        // Apply max pooling with valid padding and subdivision
        const subDivisions = [subDivision, subDivision, subDivision]
        const occupancyMapTemp = tf.maxPool3d(occupiedPadded, subDivisions, subDivisions, 'valid')
        occupiedPadded.dispose()

        // Scale the result and return
        const occupancyMap = occupancyMapTemp.mul(scalar255)
        occupancyMapTemp.dispose()
        return occupancyMap
    })
}

export function densityOccupancyMipmaps(tensor, threshold, subDivisions) 
{
    return tf.tidy(() => 
    {
        if (Math.log2(subDivisions) % 1 !== 0) throw new Error(`occupancyMipmaps: input division ${subDivisions} is not a power of 2`)

        const condition = tensor.greater(tf.scalar(threshold, 'float32'))
        const divisions = [subDivisions, subDivisions, subDivisions]

        // Pad the condition tensor to the nearest power of 2
        const conditionPadded = padCeilPow2(condition)
        condition.dispose()

        // Create the first mipmap using max pooling
        let occupancyMap = tf.maxPool3d(conditionPadded, divisions, divisions, 'same')
        conditionPadded.dispose()

        // Multiply by 255 to scale values (if needed)
        occupancyMap = occupancyMap.mul(tf.scalar(255, 'int32'))

        // Initialize mipmaps array and add the first level
        const occupancyMipmaps = [occupancyMap]

        // Calculate the number of mipmap levels
        const numMipmaps = Math.floor(Math.log2(Math.min(...tensor.shape.slice(0, 3))))

        // Generate subsequent mipmaps
        for (let level = 1; level < numMipmaps; level++) 
        {
            occupancyMipmaps.push(tf.maxPool3d(occupancyMipmaps[level - 1], [2, 2, 2], [2, 2, 2], 'same'))
        }

        return occupancyMipmaps
    })
}

export function compactMipmaps(mipmaps) 
{
    return tf.tidy(() => 
    {
        // Initialize the compact mipmaps tensor with the first mipmap, padded for space allocation.
        let compactMipmaps = mipmaps[0].pad([
            [0, mipmaps[0].shape[0] / 2],  // Pad half of the depth for the next level
            [0, 0],                        // No padding for width
            [0, 0],                        // No padding for height
            [0, 0]                         // No padding for channels
        ])

        // Initialize the offset for stacking mipmaps
        const offset = [mipmaps[0].shape[0], 0, 0, 0] // Start from the depth of the first mipmap

        // Dispose of the first mipmap as it's now incorporated into the compact tensor
        mipmaps[0].dispose()

        // Process remaining mipmap levels and combine them into the compact tensor
        for (let level = 1; level < mipmaps.length; level++) 
        {
            // Pad the current mipmap to align it within the compact tensor
            const mipmapPadded = mipmaps[level].pad(
                offset.map((dimension, i) => [dimension, compactMipmaps.shape[i] - dimension - mipmaps[level].shape[i]])
            )

            // Add the padded mipmap to the compact tensor
            const compactMipmapsTemp = compactMipmaps.add(mipmapPadded)

            // Dispose intermediate tensors to free memory
            mipmapPadded.dispose()
            compactMipmaps.dispose()

            // Dispose of the current mipmap as it's now incorporated
            mipmaps[level].dispose()

            // Update compactMipmaps with the new combined tensor
            compactMipmaps = compactMipmapsTemp

            // Update the offset for the next mipmap level
            offset[0] += mipmaps[level].shape[0] // Increment height offset by current mipmap's height
        }

        // Return the final compact tensor containing all mipmaps
        return compactMipmaps
    })
}

export function occupancyDistanceMap(tensor, threshold, division, maxIters) 
{
    return tf.tidy(() => 
    {
        const occupancy = densityOccupancyMap(tensor, threshold, division)

        let diffusionNext = occupancy.cast('bool')
        let diffusionPrev = tf.zeros(diffusionNext.shape, 'bool')
        let distanceMap = tf.zeros(diffusionNext.shape, 'int32')
    
        for (let iter = 0; iter <= maxIters; iter++) 
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
        const distanceMapUpdate = diffusionUpdate.mul(tf.scalar(maxIters, 'int32'))
        diffusionUpdate.dispose()
    
        const distanceMapTemp = distanceMap.add(distanceMapUpdate);
        distanceMapUpdate.dispose()
    
        distanceMap.dispose()
        distanceMap = distanceMapTemp
    
        return distanceMap
    })
}

export function occupancyBoundingBox(tensor, threshold) 
{
    return tf.tidy(() => 
    {
        // Create a binary mask where tensor values are greater than the threshold
        const condition = tensor.greater(tf.scalar(threshold, 'float32'))

        // Get the tensor rank (number of dimensions)
        const rank = tensor.rank

        // Compute the bounds for each axis dynamically
        const bounds = Array.from({ length: rank }, (_, axis) => boundingInterval(condition, axis))

        // Separate min and max bounds
        const minCoords = tf.stack(bounds.map(b => b[0]), 0)
        const maxCoords = tf.stack(bounds.map(b => b[1]), 0)

        // Convert tensors to arrays
        const minCoordsArray = minCoords.arraySync().slice(0, 3).toReversed()
        const maxCoordsArray = maxCoords.arraySync().slice(0, 3).toReversed()

        return { minCoords: minCoordsArray, maxCoords: maxCoordsArray}
    })
}

// Isosurface Maps

export function isosurfaceOccupancyMap(tensor, threshold = 0, subDivision = 2)
{
    return tf.tidy(() =>
    {
        const scalarThreshold = tf.scalar(threshold, 'float32')
        const scalarZero = tf.scalar(0.0, 'float32')
        const scalarEpsilon = tf.scalar(1e-6, 'float32')
        const scalar255 = tf.scalar(255, 'int32')

        const error = tensor.sub(scalarThreshold)

        const minima = minPool3d(error, [3, 3, 3], [1, 1, 1], 'same')
        const undershoot = tf.mul(minima, error)
        minima.dispose()
        const lesser = tf.less(undershoot, scalarZero)
        undershoot.dispose()

        const maxima = tf.maxPool3d(error, [3, 3, 3], [1, 1, 1], 'same')
        const overshoot = tf.mul(maxima, error)
        maxima.dispose()
        const greater = tf.less(overshoot, scalarZero)
        overshoot.dispose()
      
        const approximate = tf.logicalOr(greater, lesser);
        greater.dispose()
        lesser.dispose()

        const absError = error.abs()
        error.dispose()
        const equal = tf.lessEqual(absError, scalarEpsilon);
        absError.dispose()
        
        const condition = tf.logicalOr(equal, approximate)
        approximate.dispose()
        equal.dispose()

        if(subDivision == 1) return condition.mul(scalar255)
        const subDivisions = [subDivision, subDivision, subDivision]

        const isosurfaceMapTemp =tf.maxPool3d(condition, subDivisions, subDivisions, 'same');
        condition.dispose()
    
        const isosurfaceMap = isosurfaceMapTemp.mul(scalar255)
        isosurfaceMapTemp.dispose()
    
        return isosurfaceMap
    })
}

export function isosurfaceDistanceMap(tensor, threshold, subDivisions = 2, maxIters = 255) 
{
    return tf.tidy(() => 
    {
        console.log(tf.memory())

        // Compute isosurface map
        const isosurface = isosurfaceOccupancyMap(tensor, threshold, subDivisions)
        
        // Initialize next diffusion
        let diffusionNext = isosurface.cast('bool')
        isosurface.dispose()

        // Initialize previous diffusion
        let diffusionPrev = tf.zeros(isosurface.shape, 'bool')

        // Initialize distance map 
        let distanceMap = tf.zeros(isosurface.shape, 'int32')

        for (let iter = 0; iter <= maxIters; iter++) 
        {
            const scalarIter = tf.scalar(iter, 'int32')

            // Compute distance update
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distanceUpdate = diffusionUpdate.mul(scalarIter)
            diffusionUpdate.dispose()
            scalarIter.dispose()

            // Update distance map
            const distanceMapTemp = distanceMap.add(distanceUpdate)
            distanceUpdate.dispose()
            distanceMap.dispose()
            distanceMap = distanceMapTemp

            // Update previous diffusion 
            diffusionPrev.dispose()
            diffusionPrev = diffusionNext.clone()

            // Compute next diffusion with max pooling
            const diffusionNextTemp = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
            diffusionNext.dispose()
            diffusionNext = diffusionNextTemp
        }

        diffusionNext.dispose()
        const scalarMaxIters = tf.scalar(maxIters, 'int32')

        // Compute final distance update
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        diffusionPrev.dispose()
        const distanceUpdate = diffusionUpdate.mul(scalarMaxIters)
        diffusionUpdate.dispose()
        scalarMaxIters.dispose()

        // Update final distance map
        const distanceMapTemp = distanceMap.add(distanceUpdate)
        distanceUpdate.dispose()
        distanceMap.dispose()
        distanceMap = distanceMapTemp

        // Return the final distance map
        return distanceMap
    })
}

export function isosurfaceMapBoundingBox(tensor, threshold = 0) 
{
    return tf.tidy(() => 
    {
        const scalarThreshold = tf.scalar(threshold, 'float32')
        const scalarZero = tf.scalar(0.0, 'float32')
        const scalarEpsilon = tf.scalar(1e-6, 'float32')

        const error = tensor.sub(scalarThreshold)

        const minima = minPool3d(error, [3, 3, 3], [1, 1, 1], 'same')
        const undershoot = tf.mul(minima, error)
        minima.dispose()
        const lesser = tf.less(undershoot, scalarZero)
        undershoot.dispose()

        const maxima = tf.maxPool3d(error, [3, 3, 3], [1, 1, 1], 'same')
        const overshoot = tf.mul(maxima, error)
        maxima.dispose()
        const greater = tf.less(overshoot, scalarZero)
        overshoot.dispose()
      
        const conditionTemp = tf.logicalOr(greater, lesser);
        greater.dispose()
        lesser.dispose()

        const absError = error.abs()
        error.dispose()
        const equal = tf.lessEqual(absError, scalarEpsilon);
        error.dispose()

        const condition = tf.logicalOr(equal, conditionTemp)
        conditionTemp.dispose()
        equal.dispose()

        // Get the tensor rank (number of dimensions)
        const rank = tensor.rank

        // Compute the bounds for each axis dynamically
        const bounds = Array.from({ length: rank }, (value, axis) => boundingInterval(condition, axis))

        // Separate min and max bounds
        const minCoords = tf.stack(bounds.map(b => b[0]), 0)
        const maxCoords = tf.stack(bounds.map(b => b[1]), 0)

        // Convert tensors to arrays
        const minCoordsArray = minCoords.arraySync().slice(0, 3).toReversed()
        const maxCoordsArray = maxCoords.arraySync().slice(0, 3).toReversed()

        return { minCoords: minCoordsArray, maxCoords: maxCoordsArray}
    })
}


// Isosurface Dual Maps

export function isosurfaceOccupancyDualMap(tensor4d, threshold = 0, subDivision = 2) 
{
    return tf.tidy(() => 
    {
        // Scalars for threshold and output scaling
        const scalarThreshold = tf.scalar(threshold, 'float32')
        const scalar255 = tf.scalar(255, 'int32')

        // Symmetric padding to handle boundaries
        const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')

        // Min pooling for lower bound detection
        const minima = minPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        const lesser = tf.lessEqual(minima, scalarThreshold)
        minima.dispose()

        // Max pooling for upper bound detection
        const maxima = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        const greater = tf.greaterEqual(maxima, scalarThreshold)
        maxima.dispose()

        // Logical AND to find isosurface occupied regions
        const occupied = tf.logicalAnd(lesser, greater)
        lesser.dispose()
        greater.dispose()

        // If no subdivision is needed, scale and return
        if (subDivision === 1) {
            return occupied.mul(scalar255)
        }

        // Calculate necessary padding for valid subdivisions
        const padAmounts = occupied.shape.map((dim, i) => {
            const paddedDim = i < 3 ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
            return [0, paddedDim - dim]
        })

        // Apply padding
        const occupiedPadded = tf.pad(occupied, padAmounts)
        occupied.dispose()

        // Apply max pooling with valid padding and subdivision
        const subDivisions = [subDivision, subDivision, subDivision]
        const isosurfaceMapTemp = tf.maxPool3d(occupiedPadded, subDivisions, subDivisions, 'valid')
        occupiedPadded.dispose()

        // Scale the result and return
        const isosurfaceMap = isosurfaceMapTemp.mul(scalar255)
        isosurfaceMapTemp.dispose()

        return isosurfaceMap
    })
}

export function isosurfaceDistanceDualMap(tensor, threshold, subDivisions = 2, maxIters = 255) 
{
    return tf.tidy(() => 
    {
        // Compute isosurface map
        const isosurface = isosurfaceOccupancyDualMap(tensor, threshold, subDivisions)
        
        // Initialize next diffusion
        let diffusionNext = isosurface.cast('bool')
        isosurface.dispose()

        // Initialize previous diffusion
        let diffusionPrev = tf.zeros(isosurface.shape, 'bool')

        // Initialize distance map 
        let distanceMap = tf.zeros(isosurface.shape, 'int32')

        for (let iter = 0; iter <= maxIters; iter++) 
        {
            const scalarIter = tf.scalar(iter, 'int32')

            // Compute distance update
            const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
            const distanceUpdate = diffusionUpdate.mul(scalarIter)
            diffusionUpdate.dispose()
            scalarIter.dispose()

            // Update distance map
            const distanceMapTemp = distanceMap.add(distanceUpdate)
            distanceUpdate.dispose()
            distanceMap.dispose()
            distanceMap = distanceMapTemp

            // Update previous diffusion 
            diffusionPrev.dispose()
            diffusionPrev = diffusionNext.clone()

            // Compute next diffusion with max pooling
            const diffusionNextTemp = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
            diffusionNext.dispose()
            diffusionNext = diffusionNextTemp
        }

        diffusionNext.dispose()
        const scalarMaxIters = tf.scalar(maxIters, 'int32')

        // Compute final distance update
        const diffusionUpdate = tf.logicalNot(diffusionPrev)
        diffusionPrev.dispose()
        const distanceUpdate = diffusionUpdate.mul(scalarMaxIters)
        diffusionUpdate.dispose()
        scalarMaxIters.dispose()

        // Update final distance map
        const distanceMapTemp = distanceMap.add(distanceUpdate)
        distanceUpdate.dispose()
        distanceMap.dispose()
        distanceMap = distanceMapTemp

        // Return the final distance map
        return distanceMap
    })
}

export function isosurfaceBoundingBoxDualMap(tensor4d, threshold = 0) 
{
    return tf.tidy(() => 
    {
        // Scalars for threshold and output scaling
        const scalarThreshold = tf.scalar(threshold, 'float32')

        // Symmetric padding to handle boundaries
        const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')

        // Min pooling for lower bound detection
        const minima = minPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        const lesser = tf.lessEqual(minima, scalarThreshold)
        minima.dispose()

        // Max pooling for upper bound detection
        const maxima = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        const greater = tf.greaterEqual(maxima, scalarThreshold)
        maxima.dispose()

        // Logical AND to find isosurface occupied regions
        const occupied = tf.logicalAnd(lesser, greater)
        lesser.dispose()
        greater.dispose()

        // Compute the bounds for each axis dynamically
        const rank = tensor4d.rank
        const boundingIntervals = Array.from({ length: rank }, (_, axis) => boundingInterval(occupied, axis))

        // Separate min and max bounds
        const minCoords = tf.stack(boundingIntervals.map(interval => interval[0]), 0)
        const maxCoords = tf.stack(boundingIntervals.map(interval => interval[1]), 0)

        // Convert tensors to arrays
        const minCoordsArray = minCoords.arraySync().slice(0, 3).toReversed()
        const maxCoordsArray = maxCoords.arraySync().slice(0, 3).toReversed()

        return { minCoords: minCoordsArray, maxCoords: maxCoordsArray}
    })
}


// Extrema Maps

export function minimaMap(tensor, subDivision)
{
    return tf.tidy(() =>
    {
        const scalar2 = tf.scalar(2, 'float32')
        const subDivisions = [subDivision, subDivision, subDivision]

        // compute the min possible value inside a voxel due to trilinear interpolation
        const minimaNear = minPool3d(tensor, [3, 3, 3], [1, 1, 1], 'same')
        const minima = tf.add(tensor, minimaNear).div(scalar2)
        if (subDivision == 1) return minima

        // compute the block min value based on sub divisions
        return minPool3d(minima, subDivisions, subDivisions, 'same') 
    })
}

export function maximaMap(tensor, subDivision)
{
    return tf.tidy(() =>
    {
        const scalar2 = tf.scalar(2, 'float32')
        const subDivisions = [subDivision, subDivision, subDivision]

        // compute the max possible value inside a voxel due to trilinear interpolation
        const maximaNear = tf.maxPool3d(tensor, [3, 3, 3], [1, 1, 1], 'same')
        const maxima = tf.add(tensor, maximaNear).div(scalar2)
        if (subDivision == 1) return maxima

        // compute the block max value based on sub divisions
        return tf.maxPool3d(maxima, subDivisions, subDivisions, 'same') 
    })
}

/**
 * Computes the extrema map for a given tensor based on the method described
 * in the paper "Efficient ray casting of volumetric images using distance maps for empty space skipping".
 *
 * @param {tf.Tensor} tensor - A 3D tensor representing the input data where the extrema map is computed.
 * @param {number} subDivisions - The size of the pooling kernel in each dimension, determining the granularity of the map.
 * @returns {tf.Tensor} - A 3D tensor of the same shape as the input, containing the extrema values map.
 */
export function extremaMap(tensor, subDivision)
{
    return tf.tidy(() =>
    {
        const minimaMinimap = minimaMap(tensor, subDivision)
        const maximaMinimap = maximaMap(tensor, subDivision)
        const extremaMinimap = tf.concat([minimaMinimap, maximaMinimap], 3)            
        return extremaMinimap
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
        let [minimaMap, maximaMap] = tf.unstack(extremaMap(tensor, division), 3).map((tensor) => tensor.expandDims(-1))
        let distanceMap = tf.zeros(minimaMap.shape, 'int32')
    
        for (let iter = 0; iter <= maxDistance; iter++) 
        {
            const conditionUpdate = tf.greaterEqual (minimaMap, maximaMap)
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

// Extrema Dual Maps

export function minimaDualMap(tensor4d, subDivision)
{
    return tf.tidy(() =>
    {
        // Symmetric padding to compute dual map
        const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')

        // Min pooling for a dual cell
        const minimaDualMap = minPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        tensorPadded.dispose()
      
        // return for no subdivision
        if(subDivision == 1) return minimaDualMap

        // Calculate necessary padding for valid subdivisions
        const padAmounts = minimaDualMap.shape.map((dim, i) => {
            const paddedDim = (i < 3) ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
            return [0, paddedDim - dim]
        })
    
        // Apply padding
        const minimaDualMapPadded = tf.pad(minimaDualMap, padAmounts)
        minimaDualMap.dispose()

        // Apply max pooling with valid padding and subdivision
        const subDivisions = [subDivision, subDivision, subDivision]
        const minimaDualMinimap = tf.maxPool3d(minimaDualMapPadded, subDivisions, subDivisions, 'valid')
        minimaDualMapPadded.dispose()

        return minimaDualMinimap
    })
}

export function maximaDualMap(tensor4d, subDivision)
{
    return tf.tidy(() =>
    {
        // Symmetric padding to compute dual map
        const tensorPadded = tf.mirrorPad(tensor4d, [[1, 1], [1, 1], [1, 1], [0, 0]], 'symmetric')

        // Min pooling for a dual cell
        const maximaDualMap = tf.maxPool3d(tensorPadded, [2, 2, 2], [1, 1, 1], 'valid')
        tensorPadded.dispose()
      
        // return for no subdivision
        if(subDivision == 1) return maximaDualMap

        // Calculate necessary padding for valid subdivisions
        const padAmounts = maximaDualMap.shape.map((dim, i) => {
            const paddedDim = (i < 3) ? Math.ceil(dim / subDivision) * subDivision : dim // Only pad spatial dimensions
            return [0, paddedDim - dim]
        })
    
        // Apply padding
        const maximaDualMapPadded = tf.pad(maximaDualMap, padAmounts)
        maximaDualMap.dispose()

        // Apply max pooling with valid padding and subdivision
        const subDivisions = [subDivision, subDivision, subDivision]
        const maximaDualMinimap = tf.maxPool3d(maximaDualMapPadded, subDivisions, subDivisions, 'valid')
        maximaDualMapPadded.dispose()

        return maximaDualMinimap
    })
}

export function extremaDualMap(tensor4d, subDivision)
{
    return tf.tidy(() =>
    {
        const minimaDualMinimap = minimaDualMap(tensor4d, subDivision)
        const maximaDualMinimap = maximaDualMap(tensor4d, subDivision)
        const extremaDualMinimap = tf.concat([minimaDualMinimap, maximaDualMinimap], 3)            
        return extremaDualMinimap
    })
}
