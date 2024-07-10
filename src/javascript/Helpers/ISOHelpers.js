import * as THREE from 'three'

export default class ISOHelpers
{
    constructor(debug, viewer)
    {
        this.debug = debug
        this.viewer = viewer

        if (this.debug.active)
        {
            this.setBox()
            this.setAxis()   
            this.setBoundingBox()
            this.setPlane() 
            this.setBlocks()        
        }
    }

    update()
    {
        this.updateBoundingBox()
        this.updatePlane() 
        this.updateBlocks()  
    }

    setBox()
    {
        const box = new THREE.Box3().setFromCenterAndSize(new THREE.Vector3(), this.viewer.parameters.geometry.size)
        this.box = new THREE.Box3Helper(box, 0x119999)
        this.box.material.depthWrite = false,
        this.viewer.scene.add(this.box)
    }

    setAxis()
    {
        this.axis = new THREE.AxesHelper( 1 )
        this.axis.material.depthWrite = false,
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
        this.boundingBox = new THREE.Box3Helper(box, 0x119999)
        this.boundingBox.material.depthWrite = false,
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
        const key = `resolution${0}`

        this.blocks = {}
        this.blocks[key] = new THREE.Group()

        for (let z = 0; z < this.viewer.occupancy[key].size.z; z++) {
            const offsetZ = this.viewer.occupancy[key].size.x * this.viewer.occupancy[key].size.y * z
    
            for (let y = 0; y < this.viewer.occupancy[key].size.y; y++) {
                const offsetY = this.viewer.occupancy[key].size.x * y
    
                for (let x = 0; x < this.viewer.occupancy[key].size.x; x++) {
                    const n = x + offsetY + offsetZ

                    const blockMin = new THREE.Vector3(x, y, z)
                    const blockMax = new THREE.Vector3(x, y, z).addScalar(1)

                    const cap = new THREE.Vector3().copy(this.viewer.occupancy[key].size)
                    blockMax.min(cap)

                    const block = new THREE.Box3(blockMin, blockMax)
                    const blockHelper = new THREE.Box3Helper(block, 0x1199ff)
                    blockHelper.material.transparent = true
                    blockHelper.material.depthWrite = false
                    blockHelper.material.opacity = 0.15

                    this.blocks[key].add(blockHelper)                    
                }
            }
        }

        this.blocks[key].scale.divide(this.viewer.parameters.volume.dimensions).multiply(this.viewer.parameters.volume.size).multiply(this.viewer.occupancy[key].step)
        this.blocks[key].position.copy(this.viewer.parameters.volume.size).multiplyScalar(- 0.5)

        this.viewer.scene.add(this.blocks[key])
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

        this.blocks[key].children.forEach((blockHelper, n) => 
        {
            blockHelper.material.visible = this.viewer.occupancy[key].texture.image.data[n] > 0
        })
    }
        
}