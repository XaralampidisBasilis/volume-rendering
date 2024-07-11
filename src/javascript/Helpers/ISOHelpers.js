import * as THREE from 'three'
import * as CoordUtils from '../Utils/CoordUtils'

export default class ISOHelpers
{
    constructor(debug, viewer)
    {
        this.debug = debug
        this.viewer = viewer

        if (this.debug.active)
        {
            // this.setBox()
            // this.setAxis()   
            this.setBoundingBox()
            this.setBlocks()     
            this.setPlane()    
        }
    }

    update()
    {
        this.updateBoundingBox()
        this.updateBlocks()  
        this.updatePlane() 

    }

    setBox()
    {
        const box = new THREE.Box3().setFromCenterAndSize(new THREE.Vector3(), this.viewer.parameters.geometry.size)
        this.box = new THREE.Box3Helper(box, 0xEEE8C9)
        this.viewer.scene.add(this.box)
    }

    setAxis()
    {
        this.axis = new THREE.AxesHelper( 1 )
        // this.axis.material.depthWrite = false
        this.axis.scale.copy(this.viewer.parameters.geometry.size)
        this.axis.position.copy(this.viewer.parameters.geometry.size).multiplyScalar(- 0.5).subScalar(0.00001)
        this.viewer.scene.add(this.axis)
    }

    setBoundingBox()
    {
        const boxCenter = this.viewer.occupancy.boundingBox
            .getCenter(new THREE.Vector3())
            .multiply(this.viewer.parameters.volume.size)
            .sub(this.viewer.parameters.geometry.translation)

        const boxSize = this.viewer.occupancy.boundingBox
            .getSize(new THREE.Vector3())
            .multiply(this.viewer.parameters.volume.size)

        const box = new THREE.Box3().setFromCenterAndSize(boxCenter, boxSize)
        this.boundingBox = new THREE.Box3Helper(box, 0xFA81A2)
        // this.boundingBox.material.depthWrite = false
        this.viewer.scene.add(this.boundingBox)
    }

    setPlane()
    {
        // debug plane
        this.plane = new THREE.Mesh(
            new THREE.PlaneGeometry(this.viewer.occupancy.computation.size.width, this.viewer.occupancy.computation.size.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, transparent: false, visible: false })
        )
        this.plane.material.map = this.viewer.occupancy.getRenderTargetTexture()
        this.plane.scale.divideScalar(this.viewer.occupancy.computation.size.height)
        this.viewer.scene.add(this.plane)
    }

    setBlocks()
    {
        const blockIndex3 = new THREE.Vector3()
        const pos1 = new THREE.Vector3()
        const pos2 = new THREE.Vector3()
       
        this.blocks = {
            resolution0: new THREE.Group(),
            resolution1: new THREE.Group(),
            resolution2: new THREE.Group(),
        }

        this.children = {
            resolution0: [],
            resolution1: [],
            resolution2: [],
        }

        const blockVoxelSize = this.viewer.occupancy.resolution0.size
        const voxelIndexMax = this.viewer.parameters.volume.dimensions
        
        const division1 = new THREE.Vector3(2, 2, 2)
        const division2 = new THREE.Vector3(4, 4, 4)

        const indices1 = CoordUtils.findIndices(this.viewer.occupancy.resolution0.size, division1)
        const indices2 = CoordUtils.findIndices(this.viewer.occupancy.resolution0.size, division2)

        for (let blockIndex1 = 0; blockIndex1 < this.viewer.occupancy.resolution0.texture.image.data.length; blockIndex1++) {

            CoordUtils.ind2sub(blockVoxelSize, blockIndex1, blockIndex3)
    
            const helper = new THREE.Box3Helper(this.getVoxelBlock(blockIndex3, blockVoxelSize, voxelIndexMax), 0x00E8C9)
            helper.material.depthWrite = false
            helper.material.transparent = true
            helper.material.opacity = 0.4

            this.blocks.resolution0.add(helper)                    


            const offset1 = CoordUtils.sub2ind(
                this.viewer.occupancy.resolution1.size, 
                2 * blockIndex3[0], 
                2 * blockIndex3[1], 
                2 * blockIndex3[2]
            )

            for (let i = 0; i < indices2.length; i++) {

                CoordUtils.ind2sub(division1, i, pos1)
                
              

                block1.translate(pos1.clone().multiply(this.viewer.occupancy.resolution1.step))
                block1.max.min(block0.max)

                const blockHelper1 = new THREE.Box3Helper(block1, 0x00E8C9)
                blockHelper1.material.depthWrite = false
                blockHelper1.material.transparent = true
                blockHelper1.material.opacity = 0.4

                this.blocks.resolution1.add(blockHelper1)                    

            }

            // for (let n2 = 0; n2 < 64; n2++) {

            //     reshape1DTo3D(division2, n2, pos1)
                
            //     const block4 = new THREE.Box3().copy(block0)
            //     block4.min.divideScalar(2).ceil()
            //     block4.max.divideScalar(2).ceil().min(block0.max)

            //     const block4Helper = new THREE.Box3Helper(block4, 0x00E8C9)
            //     blockHelper.material.depthWrite = false
            //     blockHelper.material.transparent = true
            //     blockHelper.material.opacity = 0.4

            //     this.blocks.resolution2.add(block4Helper) 
            // }

        }

        this.blocks.resolution0.position.copy(this.viewer.parameters.volume.size).multiplyScalar(- 0.5)
        this.blocks.resolution1.position.copy(this.viewer.parameters.volume.size).multiplyScalar(- 0.5)

        this.blocks.resolution0.scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size)
        this.blocks.resolution1.scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size)

        this.viewer.scene.add(this.blocks.resolution0)
        this.viewer.scene.add(this.blocks.resolution1)
    }

    getVoxelBlock(blockIndex, blockVoxelSize, voxelIndexMax)
    {
        const block = new THREE.Box3()

        block.min
            .copy(blockIndex)
            .multiply(blockVoxelSize)

        block.max
            .copy(block.min)
            .add(blockVoxelSize)
            .min(voxelIndexMax)

        return block
    }

    updateBoundingBox()
    {
          const boxCenter = this.viewer.occupancy.boundingBox
                .getCenter(new THREE.Vector3())
                .multiply(this.viewer.parameters.volume.size)
                .sub(this.viewer.parameters.geometry.translation)

            const boxSize = this.viewer.occupancy.boundingBox
                .getSize(new THREE.Vector3())
                .multiply(this.viewer.parameters.volume.size)
                
        this.boundingBox.box.setFromCenterAndSize(boxCenter, boxSize)
    }

    updatePlane()
    {
        this.plane.material.map = this.viewer.occupancy.getRenderTargetTexture()

    }

    updateBlocks()
    {
        const key = `resolution${0}`

        this.blocks.resolution0.children.forEach((blockHelper0, n) => 
        {
            blockHelper0.material.visible = this.viewer.occupancy.resolution0.texture.image.data[n] > 0
        })

        this.blocks.resolution1.children.forEach((blockHelper1, n) => 
        {
            blockHelper1.material.visible = this.viewer.occupancy.resolution1.texture.image.data[n] > 0
        })
    }
        
}