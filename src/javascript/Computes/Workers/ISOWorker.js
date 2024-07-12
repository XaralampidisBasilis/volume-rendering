includeScript('WorkerUtils.js')

// reusable module scope variables for speedup

const decodedData = {
    occupiedUint64 : new Uint8Array(1),
    occupiedBytes : new Uint8Array(8),
    occupiedBits : new Uint8Array(64),
    blockMin : new Uint32Array(3),
    blockMax : new Uint32Array(3),
}

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

self.onmessage = function(event) 
{
    const inputData = event.data
    const outputData = setOutputData(inputData)

    updateSpatialData(inputData)
    processComputationData(inputData, outputData)

    self.postMessage(outputData)
}

function setOutputData(inputData) 
{
    return {
        occupied0: new Uint8Array(inputData.occumap0Length).fill(0),
        occupied1: new Uint8Array(inputData.occumap1Length).fill(0),
        occupied2: new Uint8Array(inputData.occumap2Length).fill(0),
        boxMin: new Float32Array(3).fill(+Infinity),
        boxMax: new Float32Array(3).fill(-Infinity)
    }
}

function updateSpatialData(inputData)
{
    range2ind(inputData.occumap1Dimensions, spatialData.range, spatialData.subindices1)
    range2ind(inputData.occumap2Dimensions, spatialData.range, spatialData.subindices2)
}

function processComputationData(inputData, outputData) 
{
    for (let n = 0; n < inputData.computationData.length; n += 4)
    {
        const ind0 = Math.floor(n / 4);

        decodeColorData(inputData.volumeDimensions, inputData.computationData.slice(n, n + 4));
        updateOccupancy(inputData, outputData, ind0);
        expandBox(outputData.boxMin, outputData.boxMax, decodedData.blockMin, decodedData.blockMax);
    }

    normalizeBox(outputData.boxMin, outputData.boxMax, inputData.volumeSize)
}

function decodeColorData(volumeDimensions, colorData) 
{
    const [red, green, blue, alpha] = colorData;

    resetDecodedData();
    processRedGreen(red, green);
    processBlueAlpha(blue, alpha, volumeDimensions);
}

function resetDecodedData() 
{
    decodedData.occupiedUint64.fill(0);
    decodedData.occupiedBytes.fill(0);
    decodedData.occupiedBits.fill(0);
    decodedData.blockMin.fill(+Infinity);
    decodedData.blockMax.fill(-Infinity);
}

function decodeRedGreen(red, green) 
{
    decodedData.occupiedUint64[0] = processUint32(red, 0) || processUint32(green, 4)
}

function decodeBlueAlpha(blue, alpha, volumeDimensions) 
{
    if (decodedData.occupiedUint64[0]) 
    {
        ind2sub(volumeDimensions, blue, decodedData.blockMin)
        ind2sub(volumeDimensions, alpha, decodedData.blockMax)
    }
}

function processUint32(uint32, offset) 
{   
    const hasUint32 = checkUint32(uint32)

    // if non zero uint32 detected, decode its bytes
    if (hasUint32)  
        processUint32Bytes(uint32, offset, offset + 4)

    return hasUint32
}

function processUint32Bytes(uint32, start, end)
{
    for (let byte = start; byte < end; byte++) 
    {
        decodedData.occupiedBytes[byte] = checkUint32Byte(uint32, byte);

        // if non zero byte detected, decode its bits
        if (occupiedBytes[byte]) 
            processUint32Bits(uint32, byte * 8, (byte * 8) + 8)
    }
}

function processUint32Bits(uint32, start, end)
{
    for (let bit = start; bit < end; bit++) 
        decodedData.occupiedBits[bit] = checkUint32Bit(uint32, bit);
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

    for (let i = 0; i < indices1.length; i++)
        spatialData.indices2[i] = offset2 + spatialData.subindices2[i]
}
