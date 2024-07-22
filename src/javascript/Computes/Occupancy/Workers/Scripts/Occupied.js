importScripts('Scripts/Utils')

// reusable script scope variables for speedup
const spatialData = 
{
    block0Coords : new Uint32Array(3),
    block1MinCoords : new Uint32Array(3),
    block1MaxCoords : new Uint32Array(3),
    block1Indices : new Uint32Array(8),
    block2MinCoords : new Uint32Array(3),
    block2MaxCoords : new Uint32Array(3),
    block2Indices : new Uint32Array(64),
}

function updateOccupancy(inputData, outputData, block0Index) 
{
    computeBlock12IndicesFromBlock0Index(inputData, block0Index)

    outputData.occumap0[block0Index] = decodedData.occupiedBlock[0]

    for (let i = 0; i < spatialData.block1Indices.length; i++) 
    {
        outputData.occumap1[spatialData.block1Indices[i]] = decodedData.occupiedBytes[i]        
    }

    for (let i = 0; i < spatialData.block2Indices.length; i++) 
    {
        outputData.occumap2[spatialData.block2Indices[i]] = decodedData.occupiedBits[i] 
    }
}

function computeBlock12IndicesFromBlock0Index(inputData, block0Index)
{
    ind2sub(inputData.occumap0Dimensions, block0Index, spatialData.block0Coords)

    for (let i = 0; i < 3; i++) 
    {
        spatialData.block1MinCoords[i] = spatialData.block0Coords[i] * 2
        spatialData.block2MinCoords[i] = spatialData.block0Coords[i] * 4
        spatialData.block1MaxCoords[i] = spatialData.block1MinCoords[i] + 2 - 1
        spatialData.block2MaxCoords[i] = spatialData.block2MinCoords[i] + 4 - 1
    }

    box2ind(inputData.occumap1Dimensions, spatialData.block1MinCoords, spatialData.block1MaxCoords, spatialData.block1Indices)
    box2ind(inputData.occumap2Dimensions, spatialData.block2MinCoords, spatialData.block2MaxCoords, spatialData.block2Indices)
}
