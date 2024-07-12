importScripts('Scripts/Utils.js')

// reusable script scope variables for speedup
const spatialData = {
    range: new Uint8Array([2, 2, 2]),
    coords0 : new Uint32Array(3),
    coords1 : new Uint32Array(3),
    coords2 : new Uint32Array(3),
    indices1 : new Uint32Array(8),
    indices2 : new Uint32Array(8),
    subindices1 : new Uint32Array(8),
    subindices2 : new Uint32Array(8),
}

function updateOccupancy(input, output, ind0) 
{
    // assign occupancy 0 based on decoded occupied bitstring
    output.occupied0[ind0] = decodedData.occupiedUint64[0]

    // if block 0 is occupied, check sub blocks within it
    if (output.occupied0[ind0]) 
        updateOccupancy1(input, output, ind0)
}

function updateOccupancy1(input, output, ind0) 
{
    // find linear indices of sub blocks 1 within block 0
    computeSubIndices0To1(input, ind0)
    
    // iterate through sub blocks 1 
    for (let i = 0; i < spatialData.indices1.length; i++) 
    {
        // assign occupancy 1 based on decoded occupied bytes 
        output.occupied1[spatialData.indices1[i]] = decodedData.occupiedBytes[i]

        // if block 1 is occupied, check sub blocks within it
        if (output.occupied1[spatialData.indices1[i]]) 
            updateOccupancy2(input, output, spatialData.indices1[i], i * 8)
        
    }
}

function updateOccupancy2(input, output, ind1, offset) 
{
    // find linear indices of sub blocks 2 within block 1
    computeSubIndices1To2(input, ind1)

    // iterate through sub blocks 2 
    for (let i = 0; i < spatialData.indices2.length; i++) 
        output.occupied2[spatialData.indices2[i]] = decodedData.occupiedBits[i + offset] // assign occupancy 2 based on decoded occupied bits 
    
}

function computeSubIndices0To1(input, ind0)
{
    ind2sub(input.occumap0Dimensions, ind0, spatialData.coords0)

    for (let i = 0; i < 3; i++) 
        spatialData.coords1[i] = 2 * spatialData.coords0[i]

    const offset1 = sub2ind(input.occumap1Dimensions, spatialData.coords1)

    for (let i = 0; i < spatialData.indices1.length; i++)
        spatialData.indices1[i] = offset1 + spatialData.subindices1[i]
}

function computeSubIndices1To2(input, ind1)
{
    ind2sub(input.occumap1Dimensions, ind1, spatialData.coords1)

    for (let i = 0; i < 3; i++) 
        spatialData.coords2[i] = 2 * spatialData.coords1[i]

    const offset2 = sub2ind(input.occumap1Dimensions, spatialData.coords2)

    for (let i = 0; i < spatialData.indices1.length; i++)
        spatialData.indices2[i] = offset2 + spatialData.subindices2[i]
}
