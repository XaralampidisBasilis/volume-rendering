import * as THREE from 'three'
import * as CoordUtils from '../Utils/CoordUtils.js';
export default class Occumap
{
    constructor(volumeDimensions, volumeDivisions)
    {
        this.volumeDimensions = volumeDimensions
        this.volumeDivisions = this.formatVolumeDivisions(this.volumeDimensions, volumeDivisions)
        this.blockDimensions = this.calculateBlockDimensions(this.volumeDimensions, this.volumeDivisions)
        this.dimensions = this.calculateOccumapDimensions(this.volumeDimensions, this.blockDimensions) 
        
        this.initializeOccupancyTexture(this.dimensions)
    }

    formatVolumeDivisions(volumeDimensions, volumeDivisions)
    {
        return THREE.MathUtils.clamp(volumeDivisions, 2, Math.min(...volumeDimensions.toArray()))
    }

    formatBlockDivisions(blockDimensions, blockDivisions)
    {
        return THREE.MathUtils.clamp(blockDivisions, 2, Math.min(...blockDimensions.toArray()))
    }

    formatBlockCombines(blockDimensions, blockCombines)
    {
        return THREE.MathUtils.clamp(blockCombines, 2, Math.max(...blockDimensions.toArray()))
    }

    calculateBlockDimensions(volumeDimensions, volumeDivisions)
    {
        return volumeDimensions.clone()
            .divide(volumeDivisions)
            .ceil()
    }

    calculateOccumapDimensions(volumeDimensions, blockDimensions) 
    {
        return volumeDimensions.clone()
            .divide(blockDimensions)
            .ceil()
    }

    initializeOccupancyTexture(occupancyDimensions)
    {
        if (this.texture) 
            this.texture.dispose()

        const count = occupancyDimensions.x * occupancyDimensions.y * occupancyDimensions.z
        const occupancyData = new Uint8Array(count).fill()
            
        this.texture = new THREE.Data3DTexture(occupancyData, ...occupancyDimensions.toArray())
        this.texture.format = THREE.RedFormat;
        this.texture.type = THREE.UnsignedByteType;
        this.texture.wrapS = THREE.ClampToEdgeWrapping;
        this.texture.wrapT = THREE.ClampToEdgeWrapping;
        this.texture.wrapR = THREE.ClampToEdgeWrapping;
        this.texture.minFilter = THREE.NearestFilter;
        this.texture.magFilter = THREE.NearestFilter;
        this.texture.unpackAlignment = 1;
        this.texture.needsUpdate = true;
    }

    fromArray(array)
    {
        if (this.texture.image.data.length !== array.length)
            throw new Error('input array is not the same dimensions as occupancy data')

        for (let n = 0; n < this.array.length; n++)
            this.texture.image.data[n] = array[n]

        this.texture.needsUpdate = true
    }

    toArray()
    {
        return this.texture.image.data
    }

    divideBlocks(blockDivisions)
    {        
        this.blockDivisions = this.formatBlockDivisions(this.blockDimensions, blockDivisions)
        this.blockDimensions.divide(this.blockDivisions).ceil()
        this.dimensions.multiply(this.blockDivisions)
        this.texture.image.data = this.initializeOccupancyTexture(this.dimensions)
    }

    combineBlocks(blockCombines)
    {
        this.blockCombines = this.formatBlockCombines(this.blockDimensions, blockCombines)
        this.blockDimensions.multiply(this.blockCombines)
        this.dimensions.divide(this.blockCombines).ceil()
        this.texture.image.data = this.initializeOccupancyTexture(this.dimensions)
    }

    getBlockCoords(voxelCoords)
    {
        return voxelCoords.clone().divide(this.blockDimensions).floor()
    }

    getBlockIndex(voxelCoords)
    {
        return CoordUtils.vec2ind(this.dimensions, this.getBlockCoords(voxelCoords))
    }

    getBlockBox(voxelCoords)
    {
        const blockBox = new THREE.Box3()
        const blockCoords = this.getBlockCoords(voxelCoords)
        const blockCap = volumeDimensions.clone().subScalar(1)

        blockBox.min.copy(blockCoords).multiply(this.blockDimensions)
        blockBox.max.copy(blockBox.min).add(this.blockDimensions).min(blockCap)

        return blockBox
    }

    dispose()
    {
        this.texture.dispose()
        this.volumeDimensions = null
        this.volumeDivisions = null
        this.blockDimensions = null
        this.blockDivisions = null
        this.blockCombines = null
        this.dimensions = null
        
    }
}