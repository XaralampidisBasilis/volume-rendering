importScripts('Scripts/Utils.js')

// reusable script scope variables for speedup
const spatialData = {
    divisions1: new Uint8Array([2, 2, 2]),
    divisions2: new Uint8Array([4, 4, 4]),
    coords0 : new Uint32Array(3),
    coords1 : new Uint32Array(3),
    coords2 : new Uint32Array(3),
    indices1 : new Uint32Array(8),
    indices2 : new Uint32Array(64),
    subindices1 : new Uint32Array(8),
    subindices2 : new Uint32Array(64),
}

function computeSubindices12(inputData)
{
    range2ind(inputData.occumap1Dimensions, spatialData.divisions1, spatialData.subindices1)
    range2ind(inputData.occumap2Dimensions, spatialData.divisions2, spatialData.subindices2)
}

function computeIndices12(inputData, ind0)
{
    ind2sub(inputData.occumap0Dimensions, ind0, spatialData.coords0)

    for (let i = 0; i < 3; i++) 
    {
        spatialData.coords1[i] = spatialData.divisions1[i] * spatialData.coords0[i]
        spatialData.coords2[i] = spatialData.divisions2[i] * spatialData.coords0[i]
    }

    const offset1 = sub2ind(inputData.occumap1Dimensions, spatialData.coords1)
    const offset2 = sub2ind(inputData.occumap2Dimensions, spatialData.coords2)

    for (let i = 0; i < spatialData.indices1.length; i++)
    {
        spatialData.indices1[i] = offset1 + spatialData.subindices1[i]
    }

    for ( let i = 0; i < spatialData.indices2.length; i++)
    {
        spatialData.indices2[i] = offset2 + spatialData.subindices2[i]

    }
}

function updateOccupancy(inputData, outputData, ind0) 
{
    computeIndices12(inputData, ind0)

    outputData.occupied0[ind0] = decodedData.occupiedUint64[0]

    for (let i = 0; i < spatialData.indices1.length; i++) 
        outputData.occupied1[spatialData.indices1[i]] = decodedData.occupiedBytes[i]        

    // iterate through sub blocks 2 
    for (let i = 0; i < spatialData.indices2.length; i++) 
        outputData.occupied2[spatialData.indices2[i]] = decodedData.occupiedBits[i] 

}