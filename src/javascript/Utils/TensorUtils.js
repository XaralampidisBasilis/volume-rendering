import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import everpolate from 'everpolate'
import BESSEL from 'bessel'

export async function computeDistanceSubmap(occupancyMap, begin, size, maxIterations)
{
    const occupancySubmap = tf.slice4d(occupancyMap, begin, size)
    const distanceSubmap = await computeDistanceMap(occupancySubmap, maxIterations)
    tf.dispose(occupancySubmap)

    const shape = occupancyMap.shape
    const paddings = shape.map((dimension, i) => [begin[i], dimension - begin[i] - size[i]])
    const distanceMap = tf.pad4d(distanceSubmap, paddings, 1)
    tf.dispose(distanceSubmap)

    return distanceMap
}

export async function computeDistanceMap(occupancyMap, maxIterations) 
{
    // Initialize distance map and previous/next diffusion
    let distanceMap   = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'int32'), true))
    let diffusionPrev = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'bool'), true))
    let diffusionNext = tf.tidy(() => tf.variable(tf.clone(occupancyMap), true))
    
    for (let n = 0; n <= maxIterations; n++) 
    {
        // Compute distance update
        const scalarIter = tf.scalar(n, 'int32')
        const diffusionUpdate = tf.notEqual(diffusionNext, diffusionPrev)
        const distanceUpdate = diffusionUpdate.mul(scalarIter)

        // Update distance map
        const distanceMapUpdate = distanceMap.add(distanceUpdate)
        distanceMap.assign(distanceMapUpdate)

        // Update previous diffusion state
        diffusionPrev.assign(diffusionNext)

        // Compute next diffusion with max pooling
        const diffusionNextUpdate = tf.maxPool3d(diffusionPrev, [3, 3, 3], [1, 1, 1], 'same')
        diffusionNext.assign(diffusionNextUpdate)

        // Await for garbage disposal
        tf.dispose([diffusionNextUpdate, distanceMapUpdate, distanceUpdate, diffusionUpdate, scalarIter])
        await tf.nextFrame()
    }

    // Compute final distance update
    const scalarMax = tf.scalar(maxIterations, 'int32')
    const diffusionUpdate = tf.logicalNot(diffusionPrev)
    const distanceUpdate = diffusionUpdate.mul(scalarMax)

    // Update final distance map
    distanceMap = distanceMap.add(distanceUpdate)

    // Cleanup
    tf.dispose([distanceUpdate, diffusionUpdate, scalarMax])
    tf.disposeVariables()
    await tf.nextFrame()

    // Return the final distance map
    return distanceMap
}

export async function computeBoundingBox(binaryMap) 
{
    const coords = []
    const collapsedX = binaryMap.any([1, 2, 3]) 
    coords[2] = await argBounds(collapsedX)
    tf.dispose(collapsedX)

    const collapsedYZ = binaryMap.any([0, 3]) 
    const collapsedY = collapsedYZ.any(1) 
    coords[1] = await argBounds(collapsedY)
    tf.dispose(collapsedY)

    const collapsedZ = collapsedYZ.any(0) 
    coords[0] = await argBounds(collapsedZ)
    tf.dispose([collapsedZ, collapsedYZ])

    const minCoords = [coords[0][0], coords[1][0], coords[2][0]]
    const maxCoords = [coords[0][1], coords[1][1], coords[2][1]]

    return { minCoords, maxCoords }    
}

export async function argBounds(binaryArray)
{
    const coords = await tf.whereAsync(binaryArray)
    const indices = coords.arraySync().flat()
    tf.dispose(coords)

    return (indices.length) ? [indices[0], indices[indices.length - 1]] : [0, 0]
}

export async function downscaleLinear(intensityMap, scale)
{
    const newShape = intensityMap.shape.map((size) => Math.ceil(size / scale))

    const resized0 = await resizeLinear(intensityMap, 0, newShape[0])
    await tf.nextFrame()

    const resized1 = await resizeLinear(resized0, 1, newShape[1])
    tf.dispose(resized0)
    await tf.nextFrame()

    const resized2 = await resizeLinear(resized1, 2, newShape[2])
    tf.dispose(resized1)
    await tf.nextFrame()

    const resized3 = await resizeLinear(resized2, 3, newShape[3])
    tf.dispose(resized2)
    await tf.nextFrame()

    return resized3
}

export async function downscaleNearest(binaryMap, scale)
{
    const newShape = binaryMap.shape.map((size) => Math.ceil(size / scale))

    const resized0 = await resizeNearest(binaryMap, 0, newShape[0])
    await tf.nextFrame()

    const resized1 = await resizeNearest(resized0, 1, newShape[1])
    tf.dispose(resized0)
    await tf.nextFrame()

    const resized2 = await resizeNearest(resized1, 2, newShape[2])
    tf.dispose(resized1)
    await tf.nextFrame()

    const resized3 = await resizeNearest(resized2, 3, newShape[3])
    tf.dispose(resized2)
    await tf.nextFrame()

    return resized3
}

export async function resizeLinear(tensor, axis, newSize) 
{
    return tf.tidy(() => 
    {
        // Compute indices for interpolation
        const delta = 1 / newSize
        const indices = tf.linspace(0, newSize - 1, newSize)
        const percents = indices.add(0.5).mul(delta) // normalized indices
        
        // Compute the sample indices 
        const size = tensor.shape[axis]
        const samples = percents.mul(size).sub(0.5)
        const samplesFloor = tf.clipByValue(tf.floor(samples).toInt(), 0, size - 1)  // lower indices, clipped
        const samplesCeil = tf.clipByValue(tf.ceil(samples).toInt(), 0, size - 1)    // upper indices, clipped

        // Compute interpolation weights
        const lerpWeights = samples.sub(tf.floor(samples))   // fractional part for interpolation
        const lerpShape = new Array(tensor.shape.length).fill(1)
        lerpShape[axis] = lerpWeights.size // match dimensions along the interpolation axis

        // Gather slices along the specified axis
        const expandedFloor = tf.gather(tensor, samplesFloor, axis)
        const expandedCeil = tf.gather(tensor, samplesCeil, axis)
        const expandedWeights = tf.reshape(lerpWeights, lerpShape) // reshape for broadcasting

        // Perform linear interpolation
        const interpolated = mix(expandedFloor, expandedCeil, expandedWeights)
        return interpolated
    })
}

export async function resizeNearest(tensor, axis, newSize) 
{
    return tf.tidy(() => 
    {
        // Compute new indices in normalized space
        const delta = 1 / newSize
        const indices = tf.linspace(0, newSize - 1, newSize)
        const percents = indices.add(0.5).mul(delta) // normalized indices

        // Map to the original tensor index space
        const size = tensor.shape[axis]
        const samples = percents.mul(size).sub(0.5)

        // Use nearest neighbor rounding (instead of linear interpolation)
        const nearestIndices = tf.round(samples).toInt() // Round to nearest index
        const nearestClipped = tf.clipByValue(nearestIndices, 0, size - 1) // Ensure valid indices

        // Gather values from the original tensor
        const resized = tf.gather(tensor, nearestClipped, axis)
        return resized
    });
}

export function mix(A, B, T)
{
    const difference = B.sub(A)
    tf.dispose(B)
    const offset = difference.mul(T)
    tf.dispose(T)
    const mixed = A.add(offset)
    tf.dispose(A)
    return mixed
}

