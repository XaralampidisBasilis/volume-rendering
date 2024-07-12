includeScript('Utils.js')

// reusable script scope variables for speedup
const decodedData = {
    occupiedUint64 : new Uint8Array(1),  // stores occupancy status for a 64-bit block
    occupiedUint32 : new Uint8Array(1),  // stores occupancy status for a 32-bit block
    occupiedBytes :  new Uint8Array(8),  // stores occupancy status for each byte
    occupiedBits :   new Uint8Array(64), // stores occupancy status for each bit
    blockMin :       new Uint32Array(3), // stores minimum coordinates of a block
    blockMax :       new Uint32Array(3), // stores maximum coordinates of a block
}

// decodes color data into occupancy information
function decodeColorData(volumeDimensions, colorData) 
{
    // reset decoded data
    decodedData.occupiedUint64.fill(0)
    decodedData.occupiedBytes.fill(0)
    decodedData.occupiedBits.fill(0)
    decodedData.blockMin.fill(+Infinity)
    decodedData.blockMax.fill(-Infinity)
    
    // decode color channels
    decodeRedGreen(colorData[0], colorData[1])
    decodeBlueAlpha(colorData[2], colorData[3], volumeDimensions)
}

// decodes red and green color channels
function decodeRedGreen(red, green) 
{
    decodedData.occupiedUint64[0] = occupiedUint32(red, 0) || occupiedUint32(green, 4)
}

// decodes blue and alpha color channels
function decodeBlueAlpha(blue, alpha, volumeDimensions) 
{
    // if occupied uint64 detected decode bounding block data
    if (decodedData.occupiedUint64[0]) 
    {
        ind2sub(volumeDimensions, blue,  decodedData.blockMin)
        ind2sub(volumeDimensions, alpha, decodedData.blockMax)
    }
}

// check the occupation of a 32-bit unsigned integer 
function occupiedUint32(uint32, offset) 
{   
    decodedData.occupiedUint32[0] = checkUint32(uint32)

    // if occupied uint32 detected, check byte occupation
    if (decodedData.occupiedUint32[0])  
        occupiedUint32Bytes(uint32, offset, offset + 4)

    return decodedData.occupiedUint32[0]
}

// check the occupation of a 32-bit unsigned integer bytes
function occupiedUint32Bytes(uint32, start, end)
{
    for (let byte = start; byte < end; byte++) 
    {
        decodedData.occupiedBytes[byte] = checkUint32Byte(uint32, byte)

        // if occupied byte detected, check bit occupation
        if (decodedData.occupiedBytes[byte]) 
            occupiedUint32Bits(uint32, byte * 8, (byte * 8) + 8)
    }
}

// check the occupation of a 32-bit unsigned integer bits
function occupiedUint32Bits(uint32, start, end)
{
    for (let bit = start; bit < end; bit++) 
        decodedData.occupiedBits[bit] = checkUint32Bit(uint32, bit)
}
