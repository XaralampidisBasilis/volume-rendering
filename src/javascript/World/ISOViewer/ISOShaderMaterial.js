import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/iso_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/iso_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        uCustomModelMatrix: new THREE.Uniform
        (
            new THREE.Matrix4()
        ),

        u_volume: new THREE.Uniform
        ({
            isovalue      : 0.69,
            dimensions    : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            block_size    : 0,
        }),

        u_textures: new THREE.Uniform
        ({
            interpolation_map : null,
            occupancy_map : null,
            distance_map  : null,
        }),

        u_shading: new THREE.Uniform
        ({
            reflect_ambient   : 0.2,
            reflect_diffuse   : 1.0,
            reflect_specular  : 0.6,
            shininess         : 40.0,
            modulate_edges    : 1.0,
            modulate_gradient : 1.0,
            modulate_curvature: 1.0,
        }),

        u_debug: new THREE.Uniform
        ({
            option    : 0,
            max_groups : 0,
            max_cells : 0,
            max_blocks: 0,
            variable1 : 0,
            variable2 : 0,
            variable3 : 0,
            variable4 : 0,
            variable5 : 0,
        }),
    }

    const defines = 
    {           
    
        MARCHING_METHOD     : 1,
        INTERPOLATION_METHOD: 2,
        SKIPPING_METHOD     : 2,
        GRADIENTS_METHOD    : 3,

        BERNSTEIN_ENABLED: 1,
        SKIPPING_ENABLED : 1,

        STATS_ENABLED     : 1,
        DEBUG_ENABLED     : 1,
        DISCARDING_ENABLED: 1,

        MAX_CELLS            : 1000,
        MAX_TRACES           : 5000,
        MAX_BLOCKS           : 1000,
        MAX_GROUPS           : 100,
        MAX_CELLS_PER_BLOCK  : 10,
        MAX_TRACES_PER_BLOCK : 50,
        MAX_BLOCKS_PER_GROUP : 20,
    }

    const material = new THREE.ShaderMaterial
    ({    
        side: THREE.BackSide,
        transparent: false,
        depthTest: true,
        depthWrite: true,

        glslVersion: THREE.GLSL3,
        uniforms: uniforms,
        defines: defines,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
    })

    return material
}