import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/mip_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/mip_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        u_textures: new THREE.Uniform
        ({
            intensity_map  : null,
            maxima_map     : null,
            color_maps     : null,
        }),

        u_intensity_map : new THREE.Uniform
        ({
            dimensions            : new THREE.Vector3(),
            spacing               : new THREE.Vector3(),
            size                  : new THREE.Vector3(),
            spacing_length        : 0.0,
            size_length           : 0.0,
            inv_dimensions        : new THREE.Vector3(),
            inv_spacing           : new THREE.Vector3(),
            inv_size              : new THREE.Vector3(),
            min_intensity         : 0.0,
            max_intensity         : 0.0,
        }),

        u_maxima_map : new THREE.Uniform
        ({
            sub_division    : 2,
            dimensions      : new THREE.Vector3(),
            spacing         : new THREE.Vector3(),
            size            : new THREE.Vector3(),
            inv_sub_division: 1/2,
            inv_dimensions  : new THREE.Vector3(),
            inv_spacing     : new THREE.Vector3(),
            inv_size        : new THREE.Vector3(),
        }),

        u_color_map: new THREE.Uniform
        ({
            levels      : 50,
            name        : 'viridis',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['viridis'].x_start, colormapLocations['viridis'].y),
            end_coords  : new THREE.Vector2(colormapLocations['viridis'].x_end,   colormapLocations['viridis'].y),
        }),
        
        u_rendering: new THREE.Uniform
        ({
            max_count       : 0,
            max_cell_count  : 0,
            max_block_count : 0,
        }),

        u_shading: new THREE.Uniform
        ({
            depth_focus : 0,
        }),

        u_debugging: new THREE.Uniform
        ({
            option    : 0,
            variable1 : 0,
            variable2 : 0,
            variable3 : 0,
        }),
    }

    const defines = 
    {           
        INTERSECT_BBOX_ENABLED : 1,
        SKIPPING_ENABLED       : 1,

        STATS_ENABLED          : 1,
        DEBUG_ENABLED          : 1,
        DISCARDING_DISABLED    : 0,

        MAX_CELL_COUNT         : 1000,
        MAX_BLOCK_COUNT        : 1000,
        MAX_CELL_SUB_COUNT     : 10,
        MAX_BLOCK_SUB_COUNT    : 20,
        MAX_BATCH_COUNT        : 100,
    }

    const material = new THREE.ShaderMaterial
    ({    
        side: THREE.BackSide,
        transparent: true,
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