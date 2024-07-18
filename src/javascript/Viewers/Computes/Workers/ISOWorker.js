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
        occupied0: new Uint8Array(inputData.occumap0Length).fill(0),
        occupied1: new Uint8Array(inputData.occumap1Length).fill(0),
        occupied2: new Uint8Array(inputData.occumap2Length).fill(0),
        boxMin: new Float32Array(3).fill(+Infinity),
        boxMax: new Float32Array(3).fill(-Infinity)
    }
}

function processComputationData(inputData, outputData) 
{
    for (let n = 0; n < inputData.occumap0Length; n ++)
    {
        const n4 = n * 4 // each computation block has 4 color values
        decodeColorData(inputData, inputData.computationData.slice(n4, n4 + 4))
        updateOccupancy(inputData, outputData, n)
        updateBox(outputData)
    }
    
    normalizeBox(inputData, outputData)
}

function updateBox(outputData) 
{
    for (let i = 0; i < 3; i++) 
    {
        outputData.boxMin[i] = Math.min(outputData.boxMin[i], decodedData.blockMin[i])
        outputData.boxMax[i] = Math.max(outputData.boxMax[i], decodedData.blockMax[i])
    }
}

function normalizeBox(inputData, outputData)
{
    // In order to convert voxel coordinates to model positions we need to take into account the voxel size
    // that is why we need to add to boxMax + 1 to account for the correct physical bounding box
    for (let i = 0; i < 3; i++) 
    {
        outputData.boxMin[i] = Math.max(0, Math.min(1, outputData.boxMin[i] / inputData.volumeDimensions[i]))
        outputData.boxMax[i] = Math.max(0, Math.min(1, (outputData.boxMax[i] + 1) / inputData.volumeDimensions[i]))
    }
}
