import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import computeShader from '../../../shaders/includes/precomputes/_occupancy/compute_volume_occupancy_iso.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'
import { ind2sub, box2ind } from '../../Utils/CoordUtils'

export default class ComputeOccupancy extends EventEmitter
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.renderer = this.viewer.renderer.instance
        this.scene = this.viewer.scene
        
        console.time('occupancy')
        this.set()
        this.compute()
        this.update()
        console.timeEnd('occupancy')
    }

    set()
    {
        this.setParameters()
        this.setBoundingBox()
        this.setOccupancyMap()
        this.setComputation()

        if (this.viewer.debug.active)
            this.setHelpers()
    }

    setParameters()
    {
        this.parameters = {}
        this.parameters.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.parameters.volumeDivisions = 8 * this.viewer.material.uniforms.u_occupancy.value.divisions // in order to account for 3 subdivision levels
        this.parameters.volumeDimensions = this.viewer.parameters.volume.dimensions
        this.parameters.blockDimensions = this.parameters.volumeDimensions.clone().divideScalar(this.parameters.volumeDivisions).ceil()
        this.parameters.occumapDimensions = this.parameters.volumeDimensions.clone().divide(this.parameters.blockDimensions).ceil()
        this.parameters.numBlocks = this.parameters.occumapDimensions.toArray().reduce((product, value) => product * value, 1)
    }

    setBoundingBox()
    {
        this.occubox = new THREE.Box3()
        this.occubox.min.setScalar(0)
        this.occubox.max.setScalar(1)
    }

    setOccupancyMap()
    {
        const occumapDimensions = this.parameters.occumapDimensions.toArray()
        const occumapData = new Uint8ClampedArray(this.parameters.numBlocks * 4)
        this.occumap = new THREE.Data3DTexture(occumapData, ...occumapDimensions)
        this.occumap.format = THREE.RGBAFormat
        this.occumap.type = THREE.UnsignedByteType     
        this.occumap.wrapS = THREE.ClampToEdgeWrapping
        this.occumap.wrapT = THREE.ClampToEdgeWrapping
        this.occumap.wrapR = THREE.ClampToEdgeWrapping
        this.occumap.minFilter = THREE.NearestFilter
        this.occumap.magFilter = THREE.NearestFilter
        this.occumap.unpackAlignment = 8
        this.occumap.needsUpdate = true   
    }

    setComputation()
    {         
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2
        (
            this.parameters.occumapDimensions.x, 
            this.parameters.occumapDimensions.y * this.parameters.occumapDimensions.z
        )
        this.computation.instance = new GPUComputationRenderer
        (
            this.computation.dimensions.width, 
            this.computation.dimensions.height, 
            this.renderer
        )        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Uint32Array(this.computation.texture.image.data.buffer) // shared buffer in order to decode Float32 to Uint32
        this.setComputationVariable()
        
        this.computation.instance.init()
    }

    setComputationVariable()
    {
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms = 
        {
            threshold:              new THREE.Uniform(this.parameters.threshold),
            volume_data:            new THREE.Uniform(this.viewer.textures.source),
            volume_dimensions:      new THREE.Uniform(this.parameters.volumeDimensions),
            block_dimensions:       new THREE.Uniform(this.parameters.blockDimensions),
            occumap_dimensions:     new THREE.Uniform(this.parameters.occumapDimensions),
            computation_dimensions: new THREE.Uniform(this.computation.dimensions),
        }
    }
    
    compute()
    {
        this.parameters.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.computation.variable.material.uniforms.threshold.value = this.parameters.threshold
        this.computation.instance.compute()
    }

    update()
    {
        this.readComputation()
        this.updateBoundingBox()
        this.updateOccupancyMap()

        if (this.viewer.debug.active)
            this.updateHelpers()
    }
    
    readComputation()
    {
        this.renderer.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.texture.image.data, // due to linked buffers, this.computation.data is updated also
        ) 
        this.computation.texture.needsUpdate = true;    
    }

    updateBoundingBox()
    {
        this.occubox.min.setScalar(+Infinity)
        this.occubox.max.setScalar(0)

        for (let i4 = 0; i4 < this.computation.data.length; i4 += 4)
        {
            const blockVoxelMin = ind2sub(this.parameters.volumeDimensions, this.computation.data[i4 + 2])
            const blockVoxelMax = ind2sub(this.parameters.volumeDimensions, this.computation.data[i4 + 3])
            this.occubox.min.min(blockVoxelMin)
            this.occubox.max.max(blockVoxelMax)
        }
        
        this.occubox.max.addScalar(1)
        this.occubox.max.divide(this.parameters.volumeDimensions)
        this.occubox.min.divide(this.parameters.volumeDimensions)

        console.log(this.occubox)
    }

    updateOccupancyMap()
    {
        for (let c = 0; c < 4; c++)
        {
            const size = 2 ** c
            const numBlocks = Math.ceil(this.parameters.numBlocks / size**3)

            for (let n = 0; n < numBlocks; n++)
            {
                const blockCoords = ind2sub(this.parameters.occumapDimensions.toArray(), n)
                const blockMin = blockCoords.map(x => size * Math.floor(x / size)) // calculate block min and max coordinates in 3d occumap
                const blockMax = blockMin.map(x => x + size)
            
                const indices = box2ind(this.parameters.occumapDimensions.toArray(), blockMin, blockMax) // get linear block indices in 3d occumap
                const indices4 = indices.map(i => i * 4).filter(i => i < this.computation.data.length) // convert indices to 4x values because computation has rgba values for each block
                
                const occupied = indices4.some(i4 => this.computation.data[i4 + 0] > 0) // check if any value at those indices is occupied
                if (occupied) 
                    indices4.forEach(i4 => this.occumap.image.data[i4 + c] = occupied) // update occumap texture data at the specific level
            }
        }

        this.occumap.needsUpdate = true

    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    // helpers

    setHelpers()
    {
        this.helpers = {}
        this.setComputationHelper()
        this.setOccupancyBoxHelper()
        this.helpers.computation.visible = false
        this.helpers.occubox.visible = false
    }

    setComputationHelper()
    {
        this.helpers.computation = new THREE.Mesh
        (
            new THREE.PlaneGeometry(this.computation.dimensions.width, this.computation.dimensions.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, depthTest: false })
        )
        this.helpers.computation.material.map = this.getComputationTexture()
        this.helpers.computation.scale.divideScalar(this.computation.dimensions.height)
        this.scene.add(this.helpers.computation)
    }

    setOccupancyBoxHelper()
    {
        const center = new THREE.Vector3()
        const size = new THREE.Vector3()
        const box = new THREE.Box3()

        this.occubox.getCenter(center).multiply(this.viewer.parameters.volume.size).sub(this.viewer.parameters.geometry.center)
        this.occubox.getSize(size).multiply(this.viewer.parameters.volume.size)  
        this.helpers.occubox = new THREE.Box3Helper(box.setFromCenterAndSize(center, size), 0xFFFFFF) 
        this.viewer.scene.add(this.helpers.occubox)
    }

    updateHelpers()
    {
        this.updateComputationHelper()
        this.updateOccupancyBoxHelper()
    }

    updateComputationHelper()
    {
        this.helpers.computation.material.map = this.getComputationTexture()
    }

    updateOccupancyBoxHelper()
    {
        const center = new THREE.Vector3()
        const size = new THREE.Vector3()
        this.occubox.getCenter(center).multiply(this.viewer.parameters.volume.size).sub(this.viewer.parameters.geometry.center)
        this.occubox.getSize(size).multiply(this.viewer.parameters.volume.size)  
        this.helpers.occubox.box.setFromCenterAndSize(center, size)
    }
}
