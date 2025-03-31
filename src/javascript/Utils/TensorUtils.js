import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'

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

/**
 * Computes an chebysev distance map from a binary occupancy map.
 * 
 * The algorithm simulates a wavefront expansion from occupied regions
 * in a specified axis and direction. Each voxel is assigned the step
 * (distance) at which the wavefront reaches it. Voxels not reached
 * within `maxDistance` are assigned `maxDistance` as their value.
 * 
 * @param {tf.Tensor} occupancyMap - 3D binary tensor indicating occupied voxels (1 = occupied, 0 = free)
 * @param {number} maxDistance     - Maximum number of expansion steps (voxels)
 * 
 * @returns {tf.Tensor}            - An int32 tensor of same shape as input, where each voxel holds
 *                                   its chebysev distance from the nearest occupied region
 */
export async function computeDistanceMap(occupancyMap, maxDistance) 
{
    // Initialize frontier and distances
    let frontier = tf.tidy(() => tf.variable(tf.cast(occupancyMap, 'bool'), false))
    let distances = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'int32'), false))
    
    for (let d = 1; d < maxDistance; d++) 
    {
        // Compute frontier and wavefront
        const newFrontier = tf.maxPool3d(frontier, [3, 3, 3], [1, 1, 1], 'same')
        const wavefront = tf.notEqual(newFrontier, frontier)
        frontier.assign(newFrontier)

        // Compute distance field
        const distance = tf.scalar(d, 'int32')
        const waveDistance = wavefront.mul(distance)
        const newDistances = distances.add(waveDistance)
        distances.assign(newDistances)

        // Garbage disposal
        tf.dispose([distance, wavefront, waveDistance, newDistances, newFrontier])
        await tf.nextFrame()
    }

    // Compute final wavefront
    const wavefront = tf.logicalNot(frontier)
    frontier.dispose()

    // Compute final distances
    const distance = tf.scalar(maxDistance, 'int32')
    const waveDistance = wavefront.mul(distance)
    const distanceMap = distances.add(waveDistance)
    distances.dispose()

    // Garbage disposal
    tf.dispose([distance, wavefront, waveDistance])
    await tf.nextFrame()

    // Return the final distance map
    return distanceMap
}

export async function computeAnisotropicDistanceMap(occupancyMap, maxDistance) 
{
    const directionalMaps = []
    
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 0, -1, maxDistance) )
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 1, -1, maxDistance) )
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 2, -1, maxDistance) )
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 0,  1, maxDistance) )
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 1,  1, maxDistance) )
    directionalMaps.push( await computeAnisotropicDistanceMap(occupancyMap, 2,  1, maxDistance) )

    const anisotropicDistanceMap = tf.concat(directionalMaps, 4)
    tf.dispose(directionalMaps)
    
    return anisotropicDistanceMap
}

/**
 * Computes an directional chebysev distance map from a binary occupancy map.
 * 
 * The algorithm simulates a wavefront expansion from occupied regions
 * in a specified axis and direction. Each voxel is assigned the step
 * (distance) at which the wavefront reaches it. Voxels not reached
 * within `maxDistance` are assigned `maxDistance` as their value.
 * 
 * @param {tf.Tensor} occupancyMap - 3D binary tensor indicating occupied voxels (1 = occupied, 0 = free)
 * @param {number} axis            - Axis (0, 1, or 2) along which the wavefront propagates
 * @param {number} direction       - Direction of expansion (+1 or -1) along the specified axis
 * @param {number} maxDistance     - Maximum number of expansion steps (voxels)
 * 
 * @returns {tf.Tensor}            - An int32 tensor of same shape as input, where each voxel holds
 *                                   its anisotropic distance from the nearest occupied region
 */
export async function computeDirectionalDistanceMap(occupancyMap, axis, direction, maxDistance) 
{
    // Initialize frontier and distances
    let frontier = tf.tidy(() => tf.variable(tf.cast(occupancyMap, 'bool'), false))
    let distances = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'int32'), false))

    // Initialize parameters
    const filterSize = [3, 3, 3]
    filterSize[axis] = 1
    
    for (let d = 1; d < maxDistance; d++) 
    {
        // Compute directional frontier and wavefront
        const newFrontier = tf.tidy(() => 
        {
            const shifted = shift(frontier, axis, -direction) // shift the current frontier in the opposite direction of growth
            const expanded = tf.maxPool3d(shifted, filterSize, [1, 1, 1], 'same') // expand the shifted frontier using a max pool along rest of the axes
            return tf.logicalOr(frontier, expanded) // merge the expanded frontier with the current frontier (accumulate growth)
        })
        const wavefront = tf.notEqual(newFrontier, frontier)
        frontier.assign(newFrontier)

        // Compute directional distances
        const distance = tf.scalar(d, 'int32')
        const waveDistance = wavefront.mul(distance)
        const newDistances = distances.add(waveDistance)
        distances.assign(newDistances)

        // Garbage disposal
        tf.dispose([distance, wavefront, waveDistance, newDistances, newFrontier])
        await tf.nextFrame()
    }

    // Compute final wavefront
    const wavefront = tf.logicalNot(frontier)
    frontier.dispose()

    // Compute final distances
    const distance = tf.scalar(maxDistance, 'int32')
    const waveDistance = wavefront.mul(distance)
    const distanceMap = distances.add(waveDistance)
    distances.dispose()

    // Garbage disposal
    tf.dispose([distance, wavefront, waveDistance])
    await tf.nextFrame()

    // Return the final distance map
    return distanceMap
}

/**
 * Computes an directional chebysev distance map from a binary occupancy map.
 * 
 * The algorithm simulates a wavefront expansion from occupied regions
 * in a specified axis and direction. Each voxel is assigned the step
 * (distance) at which the wavefront reaches it. Voxels not reached
 * within `maxDistance` are assigned `maxDistance` as their value.
 * 
 * @param {tf.Tensor} occupancyMap - 3D binary tensor indicating occupied voxels (1 = occupied, 0 = free)
 * @param {number} axis            - Axis (0, 1, or 2) along which the wavefront propagates
 * @param {number} direction       - Direction of expansion (+1 or -1) along the specified axis
 * @param {number} maxDistance     - Maximum number of expansion steps (voxels)
 * 
 * @returns {tf.Tensor}            - An int32 tensor of same shape as input, where each voxel holds
 *                                   its anisotropic distance from the nearest occupied region
 */
export async function computeAxialDistanceMap(occupancyMap, axis, direction, maxDistance) 
{
    // Initialize frontier and distances
    let frontier = tf.tidy(() => tf.variable(tf.cast(occupancyMap, 'bool'), false))
    let distances = tf.tidy(() => tf.variable(tf.zeros(occupancyMap.shape, 'int32'), false))

    const filter = (axis === 0) ? tf.tensor([0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], [2, 3, 3, 1, 1], 'int32') : 
                   (axis === 1) ? tf.tensor([0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], [3, 2, 3, 1, 1], 'int32') :
                   (axis === 2) ? tf.tensor([0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], [3, 3, 2, 1, 1], 'int32') : null

    // Initialize parameters
    const filterSize = [3, 3, 3]
    filterSize[axis] = 1
    
    for (let d = 1; d < maxDistance; d++) 
    {
        // Compute directional frontier and wavefront
        const newFrontier = tf.tidy(() => 
        {
            const shifted = shift(frontier, axis, -direction) // shift the current frontier in the opposite direction of growth
            const expanded = tf.maxPool3d(shifted, filterSize, [1, 1, 1], 'same') // expand the shifted frontier using a max pool along rest of the axes
            return tf.logicalOr(frontier, expanded) // merge the expanded frontier with the current frontier (accumulate growth)
        })
        const wavefront = tf.notEqual(newFrontier, frontier)
        frontier.assign(newFrontier)

        // Compute directional distances
        const distance = tf.scalar(d, 'int32')
        const waveDistance = wavefront.mul(distance)
        const newDistances = distances.add(waveDistance)
        distances.assign(newDistances)

        // Garbage disposal
        tf.dispose([distance, wavefront, waveDistance, newDistances, newFrontier])
        await tf.nextFrame()
    }

    // Compute final wavefront
    const wavefront = tf.logicalNot(frontier)
    frontier.dispose()

    // Compute final distances
    const distance = tf.scalar(maxDistance, 'int32')
    const waveDistance = wavefront.mul(distance)
    const distanceMap = distances.add(waveDistance)
    distances.dispose()

    // Garbage disposal
    tf.dispose([distance, wavefront, waveDistance])
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
    })
}

export function shift(tensor, axis, shift) 
{
    return tf.tidy(() =>
    {
        const shape = tensor.shape
        const rank = tensor.rank
        const offset = Math.abs(shift)

        const paddings = Array.from({ length: rank }, (_, i) =>
            (axis === i) ? (shift > 0 ? [offset, 0] : [0, offset]) : [0, 0]
        )

        const padded  = tf.pad(tensor, paddings)
        const shifted = tf.slice(padded, Array(rank).fill(0), shape)

        return shifted
    })
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

