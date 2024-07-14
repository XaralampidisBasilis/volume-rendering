importScripts('Scripts/Utils.js')

// reusable script scope variables for speedup
const decodedData = {
    occupiedUint64 : new Uint8Array(1),  // stores occupancy status for a 64-bit block
    occupiedBytes :  new Uint8Array(8),  // stores occupancy status for each byte
    occupiedBits :   new Uint8Array(64), // stores occupancy status for each bit
    blockMin :       new Uint32Array(3), // stores minimum coordinates of a block
    blockMax :       new Uint32Array(3), // stores maximum coordinates of a block
}

function decodeColorData(inputData, colorData) 
{
    resetDecodedData()
    decodeRedGreen(colorData[0], colorData[1])
    decodeBlueAlpha(colorData[2], colorData[3], inputData)
}

function decodeRedGreen(red, green) 
{
    decodedData.occupiedUint64[0] = checkUint32(red) || checkUint32(green)

    for (let byte = 0; byte < 4; byte++)
    {
        decodedData.occupiedBytes[byte + 0] = checkUint32Byte(red,   byte)
        decodedData.occupiedBytes[byte + 4] = checkUint32Byte(green, byte)
    }

    for (let bit = 0; bit < 32; bit++)
    {
        decodedData.occupiedBits[bit +  0] = checkUint32Bit(red,   bit)
        decodedData.occupiedBits[bit + 32] = checkUint32Bit(green, bit)
    }
}

function decodeBlueAlpha(blue, alpha, inputData) 
{
    ind2sub(inputData.volumeDimensions, blue,  decodedData.blockMin)
    ind2sub(inputData.volumeDimensions, alpha, decodedData.blockMax)
}

function resetDecodedData(inputData)
{
    decodedData.occupiedUint64.fill(0)
    decodedData.occupiedBytes.fill(0)
    decodedData.occupiedBits.fill(0)
    decodedData.blockMin.fill(+Infinity)
    decodedData.blockMax.fill(-Infinity)
}
