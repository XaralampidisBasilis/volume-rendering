importScripts('Scripts/Utils.js')

// reusable script scope variables for speedup
const spatialData = {
    blockMin1 : new Uint32Array(3),
    blockMin2 : new Uint32Array(3),
    blockMax1 : new Uint32Array(3),
    blockMax2 : new Uint32Array(3),
    coords0 : new Uint32Array(3),
    indices1 : new Uint32Array(8),
    indices2 : new Uint32Array(64),
}

function computeBlock12IndicesFromBlock0(inputData, ind0)
{
    ind2sub(inputData.occumap0Dimensions, ind0, spatialData.coords0)

    for (let i = 0; i < 3; i++) 
    {
        spatialData.blockMin1[i] = spatialData.coords0[i] * 2
        spatialData.blockMin2[i] = spatialData.coords0[i] * 4

        spatialData.blockMax1[i] = spatialData.blockMin1[i] + 2 - 1
        spatialData.blockMax2[i] = spatialData.blockMin2[i] + 4 - 1
    }

    box2ind(inputData.occumap1Dimensions, spatialData.blockMin1, spatialData.blockMax1, spatialData.indices1)
    box2ind(inputData.occumap2Dimensions, spatialData.blockMin2, spatialData.blockMax2, spatialData.indices2)

}

function updateOccupancy(inputData, outputData, ind0) 
{
    computeBlock12IndicesFromBlock0(inputData, ind0)

    outputData.occupied0[ind0] = decodedData.occupiedUint64[0]

    for (let i = 0; i < spatialData.indices1.length; i++) 
        outputData.occupied1[spatialData.indices1[i]] = decodedData.occupiedBytes[i]        

    // iterate through sub blocks 2 
    for (let i = 0; i < spatialData.indices2.length; i++) 
        outputData.occupied2[spatialData.indices2[i]] = decodedData.occupiedBits[i] 

}