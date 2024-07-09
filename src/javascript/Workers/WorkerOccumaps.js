
// module scope variables
const resolution0Sub = new Uint32Array(3)
const box_min = new Uint32Array(3)
const box_max = new Uint32Array(3)
const occumap_0 = new Uint8Array(1)
const occumap_1 = new Uint8Array(8)
const occumap_2 = new Uint8Array(64)

self.onmessage = function(event) 
{
    const data = event.data

    const { volumeSize, resolution0Size, resolution1Size, resolution2Size, computationData } = data;

    const indices1 = findInd(resolution0Size, [2, 2, 2])
    const indices2 = findInd(resolution0Size, [4, 4, 4])

    const result = {
        resolution0TextureData: new Float32Array(data.resolution0TextureData.length),
        resolution1TextureData: new Float32Array(data.resolution1TextureData.length),
        resolution2TextureData: new Float32Array(data.resolution2TextureData.length),
        boundingBoxMin: new Float32Array(3).fill(+Infinity),
        boundingBoxMax: new Float32Array(3).fill(-Infinity)
    }

    for (let resolution0Ind = 0; resolution0Ind < data.resolution0TextureData.length; resolution0Ind++) 
    {
        const n4 = resolution0Ind * 4      
        ind2sub(resolution0Size, resolution0Ind, resolution0Sub)

        decodeData(
            volumeSize,
            computationData[n4 + 0],
            computationData[n4 + 1],
            computationData[n4 + 2],
            computationData[n4 + 3]
        )

        result.resolution0TextureData[resolution0Ind] = occumap_0[0]

        const offset1 = sub2ind(
            resolution1Size, 
            2 * resolution0Sub[0], 
            2 * resolution0Sub[1], 
            2 * resolution0Sub[2]
        )

        const offset2 = sub2ind(
            resolution2Size, 
            4 * resolution0Sub[0], 
            4 * resolution0Sub[1], 
            4 * resolution0Sub[2]
        )

        for (let i = 0; i < indices1.length; i++) 
            result.resolution1TextureData[indices1[i] + offset1] = occumap_1[i]
        

        for (let i = 0; i < indices2.length; i++) 
            result.resolution2TextureData[indices2[i] + offset2] = occumap_2[i]

        expandBoundingBox(result.boundingBoxMin, result.boundingBoxMax, box_min, box_max)
    }

    normalizeBoundingBox(result.boundingBoxMin, result.boundingBoxMax, data.volumeSize)

    self.postMessage(result)
}

function decodeData(volumeSize, r, g, b, a) 
{
    occumap_0[0] |= Boolean(r)
    occumap_0[0] |= Boolean(g)

    for (let byte = 0; byte < 4; byte++) {
        occumap_1[byte + 0] = Boolean(readIntBytes(r, byte))
        occumap_1[byte + 4] = Boolean(readIntBytes(g, byte))
    }

    for (let bit = 0; bit < 32; bit++) {
        occumap_2[bit +  0] = Boolean(readIntBits(r, bit))
        occumap_2[bit + 32] = Boolean(readIntBits(g, bit))
    }

    ind2sub(volumeSize, b, box_min)
    ind2sub(volumeSize, a, box_max)   
}

function ind2sub(size, index, subscript) 
{
    subscript[0] = index % size[0]
    const yz = Math.floor(index / size[0])
    subscript[1] = yz % size[1]
    subscript[2] = Math.floor(yz / size[1])
}

function sub2ind(size, x, y, z) 
{
    return z * size[0] * size[1] + y * size[0] + x
}

function findInd(size, dimensions) 
{
    const indices = []

    for (let z = 0; z < dimensions[2]; z++) {
        const offsetZ = size[0] * size[1] * z

        for (let y = 0; y < dimensions[1]; y++) {
            const offsetY = size[0] * y

            for (let x = 0; x < dimensions[0]; x++) {
                indices.push(x + offsetY + offsetZ)
            }
        }
    }

    return indices;
}
   
function readIntBits(number, position) 
{
    return (number >> position) & 1
}

function readIntBytes(number, position) 
{
    return (number >> (position * 8)) & 0xFF
}

function expandBoundingBox(min, max, _min, _max) 
{
    for (let i = 0; i < 3; i++) 
    {
        min[i] = Math.min(min[i], _min[i])
        max[i] = Math.max(max[i], _max[i])
    }
}

function normalizeBoundingBox(min, max, volumeSize)
 {
    for (let i = 0; i < 3; i++) 
    {
        min[i] = Math.max(0, Math.min(1, min[i] / volumeSize[i]))
        max[i] = Math.max(0, Math.min(1, max[i] / volumeSize[i]))
    }
}