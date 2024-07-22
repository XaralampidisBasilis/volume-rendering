importScripts('Scripts/Utils')
importScripts('Scripts/Decode')
importScripts('Scripts/Occupied')

self.onmessage = function(event) 
{
    const inputData = event.data
    const outputData = setOutputData(inputData)
    processComputationData(inputData, outputData)

    self.postMessage(outputData)
}

function setOutputData(inputData) 
{
    return {
        occumap0: new Uint8Array(inputData.occumap0Length).fill(0),
        occumap1: new Uint8Array(inputData.occumap1Length).fill(0),
        occumap2: new Uint8Array(inputData.occumap2Length).fill(0),
        occuboxMin: new Float32Array(3).fill(1),
        occuboxMax: new Float32Array(3).fill(0),
    }
}

function processComputationData(inputData, outputData) 
{
    for (let block0Index = 0; block0Index < inputData.occumap0Length; block0Index ++)
    {
        const iBlock0Color = block0Index * 4 // each computation block has 4 color values
        decodeColorData(inputData, inputData.computationData.slice(iBlock0Color, iBlock0Color + 4))
        updateOccupancy(inputData, outputData, block0Index)
        updateBox(outputData)
    }
    normalizeBox(inputData, outputData)
}

function updateBox(outputData) 
{
    for (let i = 0; i < 3; i++) 
    {
        outputData.occuboxMin[i] = Math.min(outputData.occuboxMin[i], decodedData.bblockMinVoxelCoord[i] + 0)
        outputData.occuboxMax[i] = Math.max(outputData.occuboxMax[i], decodedData.bblockMaxVoxelCoord[i] + 1)
    }
}

function normalizeBox(inputData, outputData)
{
    for (let i = 0; i < 3; i++) 
    {
        outputData.occuboxMin[i] = Math.max(0, Math.min(1, outputData.occuboxMin[i] / inputData.volumeDimensions[i]))
        outputData.occuboxMax[i] = Math.max(0, Math.min(1, outputData.occuboxMax[i] / inputData.volumeDimensions[i]))
    }
}
