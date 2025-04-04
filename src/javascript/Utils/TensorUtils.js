import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import { int } from 'three/tsl'

/**
 * Computes a Chebyshev distance map from a 3D binary occupancy map.
 *
 * The algorithm expands a wavefront from all occupied voxels, iterating up to
 * `maxDistance`. Each voxel is assigned the iteration step at which the wavefront
 * first arrives. Voxels not reached by the wavefront within `maxDistance` steps
 * are assigned `maxDistance`.
 *
 * @param {tf.Tensor} binaryMap - 3D binary tensor indicating occupied voxels (1 = occupied, 0 = free)
 * @param {number} maxDistance  - Maximum number of expansion steps (voxels)
 *
 * @returns {tf.Tensor}         - An int32 tensor of the same shape as the input,
 *                                where each voxel holds its Chebyshev distance
 *                                to the nearest occupied voxel
 */
export async function computeDistanceMap(binaryMap, maxDistance) 
{
    // Initialize the frontier (occupied voxels) and the distance tensor
    let frontier = tf.cast(binaryMap, 'bool')
    let distances = tf.zeros(binaryMap.shape, 'int32')  
    
    for (let i = 1; i < maxDistance; i++) 
    {
        // Compute the new frontier by expanding occupied regions using 3D max pooling
        const newFrontier = tf.maxPool3d(frontier, [3, 3, 3], [1, 1, 1], 'same')
        
        // Identify the newly occupied voxels (wavefront) by comparing with the old frontier
        const wavefront = tf.notEqual(newFrontier, frontier)
        frontier.dispose()
        
        // Compute and add distances for the newly occupied voxels at this step
        const distance = tf.scalar(i, 'int32')
        const waveDistance = wavefront.mul(distance)
        const newDistances = distances.add(waveDistance)
        distances.dispose()
        
        // Update the frontier and distances for the next iteration
        frontier = newFrontier
        distances = newDistances

        // Dispose temporary tensors and yield to the next frame
        tf.dispose([distance, wavefront, waveDistance])
        await tf.nextFrame()
    }

    // Any remaining free voxels form the final wavefront
    const wavefront = tf.logicalNot(frontier)
    frontier.dispose()

    // Assign the maximum distance to voxels still not reached
    const distance = tf.scalar(maxDistance, 'int32')
    const waveDistance = wavefront.mul(distance)
    const distanceMap = distances.add(waveDistance)
    distances.dispose()

    // Dispose final temporary tensors and yield to the next frame
    tf.dispose([distance, wavefront, waveDistance])
    await tf.nextFrame()

    return distanceMap
}


export async function computeAxialDistanceMap(binaryMap, axis, direction, maxDistance) 
{
    // Initialize frontier and distances
    let frontier = (direction > 0) ? binaryMap.clone() : binaryMap.reverse(axis)
    let distances = tf.zeros(binaryMap.shape, 'int32')  

    // Initialize the directional convolution filter depending on axis
    // the shape of these filters is a cone of ones
    const filterData = [[0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], 
                        [0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1], 
                        [0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1]][axis]

    const filterSize = [[2, 3, 3, 1, 1],
                        [3, 2, 3, 1, 1],
                        [3, 3, 2, 1, 1]][axis]

    const filter = tf.tensor(filterData, filterSize, 'float32')

    // Compute chebysev distances with a frontline approach
    for (let i = 1; i < maxDistance; i++) 
    {
        // Compute directional frontier and wavefront
        const fullFrontier = tf.conv3d(frontier, filter, [1, 1, 1], 'same')
        const newFrontier = fullFrontier.cast('bool')
        const wavefront = tf.notEqual(newFrontier, frontier)
        frontier.dispose()

        // Compute directional distances
        const distance = tf.scalar(i, 'int32')
        const waveDistance = wavefront.mul(distance)
        const newDistances = distances.add(waveDistance)
        distances.dispose()

        // Update frontier and distances
        frontier = newFrontier
        distances = newDistances

        // Garbage disposal
        tf.dispose([fullFrontier, distance, wavefront, waveDistance])
        await tf.nextFrame()
    }

    // Compute final wavefront
    const wavefront = tf.logicalNot(frontier)
    frontier.dispose()

    // Compute final distances
    const distance = tf.scalar(maxDistance, 'int32')
    const waveDistance = wavefront.mul(distance)
    const newDistances = distances.add(waveDistance)
    const distanceMap = (direction > 0) ? newDistances.clone() : newDistances.reverse(axis)
    distances.dispose()

    // Garbage disposal
    tf.dispose([distance, wavefront, waveDistance, newDistances, filter])
    await tf.nextFrame()

    // Return the final distance map
    return distanceMap
}

export async function computeDistanceMapSlice(binaryMap, begin, size, maxIterations)
{
    const binaryMapSlice = tf.slice4d(binaryMap, begin, size)
    const distanceMapSlice = await computeDistanceMap(binaryMapSlice, maxIterations)
    tf.dispose(binaryMapSlice)

    const shape = binaryMap.shape
    const paddings = shape.map((dimension, i) => [begin[i], dimension - begin[i] - size[i]])
    const distanceMap = tf.pad4d(distanceMapSlice, paddings, 1)
    tf.dispose(distanceMapSlice)

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

export function minPool3d(tensor, filterSize, strides, pad)
{
    return tf.tidy(() => tf.maxPool3d(tensor.neg(), filterSize, strides, pad).neg())
} 

export function shift(tensor, axis, amount) 
{
    return tf.tidy(() =>
    {
        const shape = tensor.shape
        const rank = tensor.rank
        const offset = Math.abs(amount)

        const paddings = Array.from({ length: rank }, (_, i) =>
            (axis === i) ? (amount > 0 ? [offset, 0] : [0, offset]) : [0, 0]
        )

        const padded  = tf.pad(tensor, paddings)
        const shifted = tf.slice(padded, Array(rank).fill(0), shape)

        return shifted
    })
}

export function mix(a, b, t)
{
    return tf.tidy(() => 
    {
        const difference = b.sub(a)
        const offset = difference.mul(t)
        const result = a.add(offset)
        
        return result
    })
}

// export async function computeViewDependentCulling(intensityMap)
// {
//     // Min tensors

//     const tensor = tf.pad(intensityMap, [[1, 0], [1, 0], [1, 0], [0, 0]])
//     const shape = tensor.shape

//     let mx = minPool3d(tensor, [2, 1, 1], 1, 'same')
//     let my = minPool3d(tensor, [1, 2, 1], 1, 'same')
//     let mz = minPool3d(tensor, [1, 1, 2], 1, 'same')

//     tensor.dispose()

//     // Propagate
//     await tf.nextFrame()

//     for (let i = 0; i < 1; i++)
//     {
//         // Updates

//         const _mx = tf.tidy(() => 
//         {
//             const sx   = shift(mx, 0, -1)
//             const sy   = shift(my, 0, -1)
//             const sz   = shift(mz, 0, -1)

//             const sxy  = tf.minimum(sx, sy)
//             const sxyz = tf.minimum(sxy, sz)

//             const mxyz = tf.maximum(sxyz, mx)
    
//             return mxyz
//         })

//         await tf.nextFrame()

//         const _my = tf.tidy(() =>
//         {
//             const sx  = shift(mx, 1, -1)
//             const sz  = shift(mz, 1, -1)
    
//             const sxz = tf.minimum(sx, sz)

//             const mxyz = tf.maximum(sxz, my)
//             my.dispose()
    
//             return mxyz
//         })

//         await tf.nextFrame()

//         const _mz = tf.tidy(() =>
//         {
//             const sx  = shift(mx, 2, -1)
//             const sy  = shift(my, 2, -1)
    
//             const sxy = tf.minimum(sx, sy)

//             const mxyz = tf.maximum(sxy, mz)
//             mz.dispose()
    
//             return mxyz
//         })

//         await tf.nextFrame()

//         // Dispose
//         tf.dispose([mx, my, mz])
//         await tf.nextFrame()

//         // Reassign
//         mx = _mx
//         my = _my
//         mz = _mz

//     }

//     // Max tensors

//     const tensor2 = tf.pad(intensityMap, [[1, 1], [1, 1], [1, 1], [0, 0]])

//     const Mx = tf.tidy(() => tf.maxPool3d(tensor2, [2, 1, 1], 1, 'same').slice([1, 1, 1, 0], shape))
//     const My = tf.tidy(() => tf.maxPool3d(tensor2, [1, 2, 1], 1, 'same').slice([1, 1, 1, 0], shape))
//     const Mz = tf.tidy(() => tf.maxPool3d(tensor2, [1, 1, 2], 1, 'same').slice([1, 1, 1, 0], shape))
//     tensor2.dispose()

//     await tf.nextFrame()

//     // Condition

//     const c = tf.tidy(() => 
//     {
//         const cx   = tf.greaterEqual(mx, Mx)
//         const cy   = tf.greaterEqual(my, My)
//         const cz   = tf.greaterEqual(mz, Mz)

//         const cxy  = tf.logicalAnd(cx,  cy)
//         const cxyz = tf.logicalAnd(cxy, cz)
//         c.dispose()

//         return cxyz
//     })

//     return c
// }

export async function computeViewDependentCulling(tensor)               
{
    //           (0,1,1)                       (1,1,1)
    //              +-----------------------------+  
    //             /|                            /|
    //            / |                           / |
    //           /  |         #6 z=1           /  |
    //  (0,0,1) /   |                       (1,0,1) 
    //         +-----------------------------+    |
    //         |    |            #5 y=1      |    |
    //         |    |                        |    |
    //         | #1 x=0                      | #4 x=1
    //         |    |                        |    |
    //         |    |        #2 y=0          |    |
    //  (0,1,0)|    +------------------------|----+ (1,1,0)
    //         |   /                         |   / 
    //         |  /           #3 z=0         |  /  
    //         | /                           | /   
    //         |/                            |/    
    //         +-----------------------------+    
    //    (0,0,0)                            (1,0,0)
    //    

    const shape = tensor.shape.map((x) => x - 1)
    shape[3] = tensor.shape[3]

    // Positive propagation

    // min(face#1) >= max(face#4)
    const c14 = tf.tidy(() =>
    {
        const m1 =    minPool3d(tensor, [1, 2, 2], 1, 'valid').slice([0, 0, 0, 0], shape)
        const M4 = tf.maxPool3d(tensor, [1, 2, 2], 1, 'valid').slice([1, 0, 0, 0], shape)
        return tf.greaterEqual(m1, M4)
    })
   
    await tf.nextFrame()

    // min(face#2) >= max(face#5)
    const c25 = tf.tidy(() =>
    {
        const m2 =    minPool3d(tensor, [2, 1, 2], 1, 'valid').slice([0, 0, 0, 0], shape)
        const M5 = tf.maxPool3d(tensor, [2, 1, 2], 1, 'valid').slice([0, 1, 0, 0], shape)
        return tf.greaterEqual(m2, M5)
    })
   
    await tf.nextFrame()

    // min(face#1) >= max(face#4) && min(face#2) >= max(face#5)
    const c12 = tf.logicalAnd(c14, c25)
    tf.dispose([c14, c25])

    await tf.nextFrame()

    // min(face#3) >= max(face#6)
    const c36 = tf.tidy(() =>
    {
        const m3 =    minPool3d(tensor, [2, 2, 1], 1, 'valid').slice([0, 0, 0, 0], shape)
        const M6 = tf.maxPool3d(tensor, [2, 2, 1], 1, 'valid').slice([0, 0, 1, 0], shape)
        return tf.greaterEqual(m3, M6)
    
    })
   
    await tf.nextFrame()

    // min(face#1) >= max(face#4) && min(face#2) >= max(face#5) && min(face#3) >= max(face#6)
    const c123 =  tf.logicalAnd(c12, c36)
    tf.dispose([c12, c36])

    await tf.nextFrame()

    // Negative propagation

    // min(face#4) >= max(face#1)
    const c41 = tf.tidy(() =>
    {
        const m4 =    minPool3d(tensor, [1, 2, 2], 1, 'valid').slice([1, 0, 0, 0], shape)
        const M1 = tf.maxPool3d(tensor, [1, 2, 2], 1, 'valid').slice([0, 0, 0, 0], shape)
        return tf.greaterEqual(m4, M1)
    })
       
    await tf.nextFrame()

    // min(face#5) >= max(face#2)
    const c52 = tf.tidy(() =>
    {
        const m5 =    minPool3d(tensor, [2, 1, 2], 1, 'valid').slice([0, 1, 0, 0], shape)
        const M2 = tf.maxPool3d(tensor, [2, 1, 2], 1, 'valid').slice([0, 0, 0, 0], shape)
        return tf.greaterEqual(m5, M2)
    })
       
    await tf.nextFrame()

    // min(face#4) >= max(face#1) && min(face#5) >= max(face#2)
    const c45 = tf.logicalAnd(c41, c52)
    tf.dispose([c41, c52])

    await tf.nextFrame()

    // min(face#6) >= max(face#3)
    const c63 = tf.tidy(() =>
    {
        const m6 =    minPool3d(tensor, [2, 2, 1], 1, 'valid').slice([0, 0, 1, 0], shape)
        const M3 = tf.maxPool3d(tensor, [2, 2, 1], 1, 'valid').slice([0, 0, 0, 0], shape)
        return tf.greaterEqual(m6, M3)
    })
       
    await tf.nextFrame()

    // min(face#4) >= max(face#1) && min(face#5) >= max(face#2) && min(face#6) >= max(face#3)
    const c456 =  tf.logicalAnd(c45, c63)
    tf.dispose([c45, c63])

    await tf.nextFrame()

    // Combination

    // (min(face#1) >= max(face#4) && min(face#2) >= max(face#5) && min(face#3) >= max(face#6)) ||
    // (min(face#4) >= max(face#1) && min(face#5) >= max(face#2) && min(face#6) >= max(face#3))
    const c = tf.logicalOr(c123, c456)
    tf.dispose([c123, c456])

    await tf.nextFrame()

    return c
}

export async function computeViewDependentCullingPatches(tensor)
{
    console.time('computeViewDependentCullingPatches')

    const shape = tensor.shape
    const patchDivisions = [4, 4, 4, 1]
    
    const patchSize = shape.map((x, i) => Math.max(Math.ceil(x / patchDivisions[i]), 1))
    const stride = patchSize.map(x => Math.max(x - 1, 1))

    const [shapeZ, shapeY, shapeX, shapeT] = shape
    const [patchZ, patchY, patchX, patchT] = patchSize
    const [strideZ, strideY, strideX, strideT] = stride

    const mapShape = shape.map((x) => x - 1)
    mapShape[3] = shape[3]
    let map = tf.zeros(mapShape, 'bool')  

    for (let beginZ = 0; beginZ <= shapeZ - patchZ; beginZ += strideZ) {
        for (let beginY = 0; beginY <= shapeY - patchY; beginY += strideY) {
            for (let beginX = 0; beginX <= shapeX - patchX; beginX += strideX) {
                for (let beginT = 0; beginT <= shapeT - patchT; beginT += strideT) 
                {
                    const begin = [beginZ, beginY, beginT, beginT]
                    const sliceSize = patchSize.map((x, i) => Math.min(shape[i] - begin[i], patchSize[i]))
                
                    const slice = tensor.slice(begin, sliceSize)
                    const patch = await computeViewDependentCulling(slice)
                    tf.dispose(slice)

                    const paddings = shape.map((x, i) => [begin[i],  shape[i] - begin[i] - sliceSize[i]])
                    const paddedPatch = tf.pad(patch, paddings)
                    tf.dispose(patch)

                    const newMap = tf.logicalOr(map, paddedPatch)
                    tf.dispose([map, paddedPatch])
                    map = newMap                
                }
            }
        }
    }

    tf.tidy(() => console.log(map.sum().arraySync()/map.size * 100))

    console.timeEnd('computeViewDependentCullingPatches')
}

// export async function computeViewDependentCullingPatches2(tensor)
// {
//     console.time('computeViewDependentCullingPatches')

//     const shape = tensor.shape
//     const patchDivisions = [8, 1, 1, 1]

//     const patchSize = shape.map((x, i) => Math.max(Math.ceil(x / patchDivisions[i]), 1))
//     const stride = patchSize.map(x => Math.max(x - 1, 1))

//     const [shapeZ, shapeY, shapeX, shapeT] = shape
//     const [patchZ, patchY, patchX, patchT] = patchSize
//     const [strideZ, strideY, strideX, strideT] = stride

//     let map = tf.zeros(shape, 'bool')  
//     let count = 0

//     for (let beginZ = 0; beginZ <= shapeZ - patchZ; beginZ += strideZ) {
//         for (let beginY = 0; beginY <= shapeY - patchY; beginY += strideY) {
//             for (let beginX = 0; beginX <= shapeX - patchX; beginX += strideX) {
//                 for (let beginT = 0; beginT <= shapeT - patchT; beginT += strideT) 
//                 {
//                     const begin = [beginZ, beginY, beginT, beginT]
//                     const sliceSize = patchSize.map((x, i) => Math.min(shape[i] - begin[i], patchSize[i]))
                
//                     const slice = tensor.slice(begin, sliceSize)
//                     const patch = await computeViewDependentCulling(slice)
//                     tf.dispose(slice)

//                     const patchIndices = await tf.whereAsync(patch)
//                     const offset = tf.tensor1d(begin, 'int32')
//                     const indices = patchIndices.add(offset)
//                     const updates = tf.ones([indices.shape[0]], 'bool')
//                     tf.dispose([offset, patchIndices])

//                     const newMap = tf.tensorScatterUpdate(map, indices, updates)
//                     tf.dispose([map, indices, updates])
//                     map = newMap

//                     console.log(count)
//                     count++
//                 }
//             }
//         }
//     }

//     console.timeEnd('computeViewDependentCullingPatches')
// }
