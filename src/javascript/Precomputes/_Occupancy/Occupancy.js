import * as THREE from 'three'
import EventEmitter from '../../Utils/EventEmitter'
import computeShader from '../../../shaders/includes/precomputes/occupancy/compute_volume_occupancy_iso.glsl'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'
import * as COORDS from '../../Utils/CoordUtils'

export default class Occupancy extends EventEmitter
{
    constructor(viewer)
    {
        super()

        this.viewer = viewer
        this.renderer = this.viewer.renderer.instance
        this.scene = this.viewer.scene
        this.threshold = this.viewer.material.uniforms.u_raycast.value.threshold
        this.divisions = this.viewer.material.uniforms.u_occupancy.value.divisions 

        console.time('occupancy')
        this.setBoundingBox()
        this.setOccupancyMap()
        this.setComputation()
        this.compute()
        this.readComputation()
        console.timeEnd('occupancy')
    }

    setBoundingBox()
    {
        this.bbox = new THREE.Box3()
        this.bbox.min.setScalar(0)
        this.bbox.max.setScalar(1)
    }

    setOccupancyMap()
    {
        this.occumap = {}

        this.occumap.volumeDimensions = this.viewer.parameters.volume.dimensions
        this.occumap.volumeSubdivisions = 8 * this.divisions // in order to account for 3 subdivision levels
        this.occumap.blockDimensions = volumeDimensions.clone().divideScalar(this.occumap.volumeSubdivisions).ceil()
        this.occumap.occumapDimensions = volumeDimensions.clone().divide(this.occumap.blockDimensions).ceil()
                
        const occumapDimensions = this.occumap.occumapDimensions.toArray()
        this.occumap.occumapCount = occumapDimensions.reduce((product, value) => product * value, 1);
        const occumapData = new Uint8ClampedArray(this.occumap.occumapCount * 4)

        this.occumap.texture = new THREE.Data3DTexture(occumapData, ...occumapDimensions)
        this.occumap.texture.format = THREE.RGBAFormat
        this.occumap.texture.type = THREE.UnsignedByteType     
        this.occumap.texture.wrapS = THREE.ClampToEdgeWrapping
        this.occumap.texture.wrapT = THREE.ClampToEdgeWrapping
        this.occumap.texture.wrapR = THREE.ClampToEdgeWrapping
        this.occumap.texture.minFilter = THREE.NearestFilter
        this.occumap.texture.magFilter = THREE.NearestFilter
        this.occumap.texture.needsUpdate = true   
        this.occumap.texture.unpackAlignment = 8
    }

    setComputation()
    {         
        this.computation = {}
        this.computation.dimensions = new THREE.Vector2
        (
            this.occumap.occumapDimensions.x, 
            this.occumap.occumapDimensions.y * this.occumap.occumapDimensions.z
        )
        this.computation.instance = new GPUComputationRenderer
        (
            this.computation.dimensions.width, 
            this.computation.dimensions.height, 
            this.renderer.instance
        )        
        this.computation.instance.setDataType(THREE.FloatType) 
        this.computation.texture = this.computation.instance.createTexture()
        this.computation.data = new Float32Array(this.computation.texture.image.data.length) 
        this.setComputationVariable()
        
        this.computation.instance.init()
    }

    setComputationVariable()
    {
        this.computation.variable = this.computation.instance.addVariable('v_computation_data', computeShader, this.computation.texture)
        this.computation.instance.setVariableDependencies(this.computation.variable, [this.computation.variable])
        this.computation.variable.material.uniforms = 
        {
            threshold:              new THREE.Uniform(this.threshold),
            volume_data:            new THREE.Uniform(this.viewer.textures.source),
            volume_dimensions:      new THREE.Uniform(this.occumap.volumeDimensions),
            block_dimensions:       new THREE.Uniform(this.occumaps.blockDimensions),
            occumap_dimensions:     new THREE.Uniform(this.occumaps.occumapDimensions),
            computation_dimensions: new THREE.Uniform(this.computation.dimensions),      
        }
    }
    
    compute()
    {
        this.computation.instance.compute()
    }
    
    readComputation()
    {
        this.renderer.instance.readRenderTargetPixels(
            this.computation.instance.getCurrentRenderTarget(this.computation.variable),
            0, 
            0, 
            this.computation.dimensions.width, 
            this.computation.dimensions.height,
            this.computation.data, 
        )     
    }

    parseComputation()
    {
        const numBlocks0 = this.computation.data.length / 4 / 1**3
        for (let i = 0; i < numBlocks0; i += 4)
        {
            const i4 = i * 4
            this.occumap.texture.image.data[i4 + 0] = this.computation.data[i4 + 0]
        }

        const numBlocks1 = this.computation.data.length / 4 / 2**3
        for (let i = 0; i < numBlocks1; i += 4)
        {
            const i4 = i * 4
            this.occumap.texture.image.data[i4 + 1] = this.computation.data[i4 + 0]

        }

        const numBlocks2 = this.computation.data.length / 4 / 4**3
        for (let i = 0; i < numBlocks2; i += 4)
        {
            const i4 = i * 4
            this.occumap.texture.image.data[i4 + 2] = this.computation.data[i4 + 0]

        }

        const numBlocks3 = this.computation.data.length / 4 / 8**3
        for (let i = 0; i < numBlocks3; i += 4)
        {
            const i4 = i * 4
            this.occumap.texture.image.data[i4 + 3] = this.computation.data[i4 + 0]

        }
    }
}
