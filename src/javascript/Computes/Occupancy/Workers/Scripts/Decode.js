importScripts('Scripts/Utils')

// reusable script scope variables for speedup
const decodedData = 
{
    occupiedBlock: new Uint8Array(1),  // stores occupancy status for a 64-bit block
    occupiedBytes:  new Uint8Array(8),  // stores occupancy status for each byte
    occupiedBits:   new Uint8Array(64), // stores occupancy status for each bit
    bblockMinVoxelCoord: new Uint32Array(3), // stores minimum position of a block
    bblockMaxVoxelCoord: new Uint32Array(3), // stores maximum position of a block
}

const parameters = 
{
    byteDimensions: new Uint8Array([2, 2, 2]),
    bitDimensions: new Uint8Array([4, 4, 4]),
    byteCoords: new Uint8Array(3),
    bitIndices: new Uint8Array(8),
    byteIndices: new Uint8Array([0, 1, 2, 3, 4, 5, 6, 7]),
    bitCoordMin: new Uint8Array(3),
    bitCoordMax: new Uint8Array(3),
}

function decodeColorData(inputData, colorData) 
{
    resetDecodedData(inputData)
    decodeRedGreen(colorData[0], colorData[1])
    decodeBlueAlpha(colorData[2], colorData[3], inputData)
}

function resetDecodedData(inputData)
{
    decodedData.occupiedBlock.fill(0)
    decodedData.occupiedBytes.fill(0)
    decodedData.occupiedBits.fill(0)
    decodedData.bblockMaxVoxelCoord.fill(0)
    for (let i = 0; i < 3; i++)
    {
        decodedData.bblockMinVoxelCoord[i] = inputData.volumeDimensions[i] - 1
    }
}

function decodeRedGreen(red, green) 
{
    for (let bit = 0; bit < 32; bit++)
    {
        decodedData.occupiedBits[bit +  0] = checkUint32Bit(red,   bit)
        decodedData.occupiedBits[bit + 32] = checkUint32Bit(green, bit)
    }

    for (let byte = 0; byte < 8; byte++)
    {
        computeBitIndicesFromByte(byte)
        decodedData.occupiedBytes[byte] = parameters.bitIndices.some((bit) => decodedData.occupiedBits[bit]);
    }

    decodedData.occupiedBlock[0] = parameters.byteIndices.some((byte) => decodedData.occupiedBytes[byte]);
}

function decodeBlueAlpha(blue, alpha, inputData) 
{
    ind2sub(inputData.volumeDimensions, blue,  decodedData.bblockMinVoxelCoord)
    ind2sub(inputData.volumeDimensions, alpha, decodedData.bblockMaxVoxelCoord)
}

function computeBitIndicesFromByte(byte)
{
    ind2sub(parameters.byteDimensions, byte, parameters.byteCoords)

    for (let i = 0; i < 3; i++) 
    {
        parameters.bitCoordMin[i] = parameters.byteCoords[i] * 2
        parameters.bitCoordMax[i] = parameters.bitCoordMin[i] + 2 - 1
    }

    box2ind(parameters.bitDimensions, parameters.bitCoordMin, parameters.bitCoordMax, parameters.bitIndices)
}


