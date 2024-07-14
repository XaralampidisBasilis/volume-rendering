importScripts('Scripts/Utils.js')

// reusable script scope variables for speedup
const decodedData = {
    occupiedUint64 : new Uint8Array(1),  // stores occupancy status for a 64-bit block
    occupiedUint32 : new Uint8Array(2),  // stores occupancy status for a 32-bit block
    occupiedBytes :  new Uint8Array(8),  // stores occupancy status for each byte
    occupiedBits :   new Uint8Array(64), // stores occupancy status for each bit
    blockMin :       new Uint32Array(3), // stores minimum coordinates of a block
    blockMax :       new Uint32Array(3), // stores maximum coordinates of a block
}

// decodes color data into occupancy information
function decodeColorData(inputData, colorData) 
{
    resetDecodedData()
    decodeRedGreen(colorData[0], colorData[1])
    decodeBlueAlpha(colorData[2], colorData[3], inputData)
}

// decodes red and green color channels
function decodeRedGreen(red, green) 
{
    decodedData.occupiedUint64[0] = Boolean(occupiedUint32(red, 0) + occupiedUint32(green, 1))
}

// decodes blue and alpha color channels
function decodeBlueAlpha(blue, alpha, inputData) 
{
    // if occupied uint64 detected decode bounding block data
    if (decodedData.occupiedUint64[0]) 
    {
        ind2sub(inputData.volumeDimensions, blue,  decodedData.blockMin)
        ind2sub(inputData.volumeDimensions, alpha, decodedData.blockMax)
    }
}

// check the occupation of a 32-bit unsigned integer 
function occupiedUint32(uint32, offset) 
{   
    decodedData.occupiedUint32[offset] = checkUint32(uint32)

    // if occupied uint32 detected, check byte occupation
    if (decodedData.occupiedUint32[0])  
        occupiedUint32Bytes(uint32, offset * 4)

    return decodedData.occupiedUint32[offset]
}

// check the occupation of a 32-bit unsigned integer bytes
function occupiedUint32Bytes(uint32, byteOffset)
{
    for (let byteIndex = 0; byteIndex < 4; byteIndex++) 
    {
        const byte = readUint32Byte(uint32, byteIndex)
        decodedData.occupiedBytes[byteIndex + byteOffset] = Boolean(byte)

        // if occupied byte detected, check bit occupation
        if (decodedData.occupiedBytes[byteIndex + byteOffset]) 
            occupiedByteBits(byte, (byteIndex + byteOffset) * 8)
    }
}

// check the occupation of a byte bits
function occupiedByteBits(byte, bitOffset)
{
    for (let bitIndex = 0; bitIndex < 8; bitIndex++) 
        decodedData.occupiedBits[bitIndex + bitOffset] = checkByteBit(byte, bitIndex)
}

function resetDecodedData()
{
    decodedData.occupiedUint64.fill(0)
    decodedData.occupiedBytes.fill(0)
    decodedData.occupiedBits.fill(0)
    decodedData.blockMin.fill(+Infinity)
    decodedData.blockMax.fill(-Infinity)
}