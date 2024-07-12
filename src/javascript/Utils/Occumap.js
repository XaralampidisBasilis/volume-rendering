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
        return Math.floor(THREE.MathUtils.clamp(volumeDivisions, 1, Math.min(...volumeDimensions.toArray())))
    }

    formatBlockDivisions(blockDimensions, blockDivisions)
    {
        return Math.floor(THREE.MathUtils.clamp(blockDivisions, 1, Math.min(...blockDimensions.toArray())))
    }

    formatBlockCombines(blockDimensions, blockCombines)
    {
        return Math.floor(THREE.MathUtils.clamp(blockCombines, 1, Math.max(...blockDimensions.toArray())))
    }

    calculateBlockDimensions(volumeDimensions, volumeDivisions)
    {
        return volumeDimensions.clone()
            .divideScalar(volumeDivisions)
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
        const count = occupancyDimensions.x * occupancyDimensions.y * occupancyDimensions.z
        this.data = new Uint8Array(count).fill()
            
        this.texture = new THREE.Data3DTexture(this.data, ...occupancyDimensions.toArray())
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

        for (let n = 0; n < array.length; n++)
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
        this.blockDimensions.divideScalar(this.blockDivisions).ceil()
        this.dimensions.multiplyScalar(this.blockDivisions)

        if (this.texture) this.texture.dispose()
        this.initializeOccupancyTexture(this.dimensions)

        return this
    }

    combineBlocks(blockCombines)
    {
        this.blockCombines = this.formatBlockCombines(this.blockDimensions, blockCombines)
        this.blockDimensions.multiplyScalar(this.blockCombines)
        this.dimensions.divideScalar(this.blockCombines).ceil()

        if (this.texture) this.texture.dispose()
        this.initializeOccupancyTexture(this.dimensions)

        return this
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