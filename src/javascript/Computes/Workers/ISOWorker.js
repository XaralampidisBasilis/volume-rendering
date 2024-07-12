importScripts('Scripts/Utils.js')
importScripts('Scripts/Decode.js')
importScripts('Scripts/Occupied.js')

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
    computeSubindices(inputData)

    for (let n = 0; n < inputData.computationData.length; n += 4)
    {
        const ind0 = Math.floor(n / 4)

        decodeColorData(inputData, inputData.computationData.slice(n, n + 4))
        updateOccupancy(inputData, outputData, ind0)
        expandBox(outputData.boxMin, outputData.boxMax, decodedData.blockMin, decodedData.blockMax)
    }
    
    normalizeBox(inputData.volumeDimensions, outputData.boxMin, outputData.boxMax)
}

