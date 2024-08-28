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
        this.setParameters()
        this.setBoundingBox()
        this.setOccupancyMap()
        this.setComputation()
        this.compute()
        this.readComputation()
        this.parseComputation()
        console.timeEnd('occupancy')

        if (this.viewer.debug.active)
        {
            // this.setComputationHelper()
        }
        this.on('ready', () =>
        {
            // this.updateComputationHelper()
        })
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
        this.bbox = new THREE.Box3()
        this.bbox.min.setScalar(0)
        this.bbox.max.setScalar(1)
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
        this.computation.instance.compute()
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

    parseComputation()
    {
        for (let level = 0; level < 4; level++)
        {
            const size = 2 ** level
            const numBlocks = Math.ceil(this.parameters.numBlocks / size**3)

            for (let blockIndex = 0; blockIndex < numBlocks; blockIndex++)
            {
                const blockCoords = ind2sub(this.parameters.occumapDimensions.toArray(), blockIndex)
                const blockMin = blockCoords.map(coord => size * Math.floor(coord / size)) // calculate block min and max coordinates in 3d occumap
                const blockMax = blockMin.map(coord => coord + size)
            
                const indices = box2ind(this.parameters.occumapDimensions.toArray(), blockMin, blockMax) // get linear block indices in 3d occumap
                const indices4 = indices.map(index => index * 4).filter(index => index < this.computation.data.length) // convert indices to 4x values because computation has rgba values for each block
                const occupied = indices4.some(index4 => this.computation.data[index4 + 0] > 0) // check if any value at those indices is occupied
            
                // update occumap texture data at the specific level
                indices4.forEach(index4 => 
                {
                    this.occumap.image.data[index4 + level] = occupied
                })
            }
        }

    }

    getComputationTexture()
    {
        return this.computation.instance.getCurrentRenderTarget(this.computation.variable).texture
    }

    setComputationHelper()
    {
        this.computation.helper = new THREE.Mesh
        (
            new THREE.PlaneGeometry(this.computation.dimensions.width, this.computation.dimensions.height),
            new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, depthTest: false })
        )
        this.computation.helper.material.map = this.getComputationTexture()
        this.computation.helper.scale.divideScalar(this.computation.dimensions.height)
        this.scene.add(this.computation.helper)
    }

    updateComputationHelper()
    {
        this.computation.helper.material.map = this.getComputationTexture()
    }
}
