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
            intensity_map           : null,
            color_maps              : null,
            maxima_map              : null,
            distance_map            : null,
            anisotropic_distance_map: null,
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
            sub_division    : 8,
            inv_sub_division: 1/8,
            dimensions      : new THREE.Vector3(),
            spacing         : new THREE.Vector3(),
            size            : new THREE.Vector3(),
            inv_dimensions  : new THREE.Vector3(),
            inv_spacing     : new THREE.Vector3(),
            inv_size        : new THREE.Vector3(),
        }),

        u_distance_map : new THREE.Uniform
        ({
            max_iterations  : 100,
            max_distance    : 100,
            dimensions      : new THREE.Vector3(),
            spacing         : new THREE.Vector3(),
            size            : new THREE.Vector3(),
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
        PRE_MARCHING_ENABLED   : 1,
        SKIPPING_ENABLED       : 1,

        STATS_ENABLED          : 1,
        DEBUG_ENABLED          : 1,
        DISCARDING_DISABLED    : 0,

        MAX_TRACE_COUNT        : 100,
        MAX_CELL_COUNT         : 100,
        MAX_CELL_SUBCOUNT      : 100,
        MAX_BLOCK_COUNT        : 100,
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