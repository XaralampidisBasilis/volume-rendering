import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/iso_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/iso_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        u_volume: new THREE.Uniform
        ({
            size          : new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            dimensions    : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            anisotropy    : new THREE.Vector3(),
            blocks        : new THREE.Vector3(),
            stride        : 0,
            grid_matrix   : new THREE.Matrix4(),
        }),

        u_textures: new THREE.Uniform
        ({
            colormaps    : null,
            trilinear_volume : null,
            tricubic_volume : null,
            occupancy : null,
            isotropic_distance  : null,
            anisotropic_distance : null,
            extended_distance : null,
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
        }),

        u_bbox : new THREE.Uniform
        ({
            min_cell_coords : new THREE.Vector3(),
            max_cell_coords : new THREE.Vector3(),
            min_block_coords: new THREE.Vector3(),
            max_block_coords: new THREE.Vector3(),
            min_position    : new THREE.Vector3(),
            max_position    : new THREE.Vector3(),
        }),

        u_distance_map : new THREE.Uniform
        ({
            max_distance    : 0,
            max_iterations  : 31,
            stride          : 2,
            dimensions      : new THREE.Vector3(),
            spacing         : new THREE.Vector3(),
            size            : new THREE.Vector3(),
            inv_stride      : 1/4,
            inv_dimensions  : new THREE.Vector3(),
            inv_spacing     : new THREE.Vector3(),
            inv_size        : new THREE.Vector3(),
        }),

        u_colormap: new THREE.Uniform
        ({
            levels      : 255,
            name        : 'cet_d9',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['cet_d9'].x_start, colormapLocations['cet_d9'].y),
            end_coords  : new THREE.Vector2(colormapLocations['cet_d9'].x_end,   colormapLocations['cet_d9'].y),
        }),
        
        u_rendering: new THREE.Uniform
        ({
            isovalue : 0.69,
            max_groups : 0,
            max_cells : 0,
            max_blocks: 0,
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
        
        u_lighting: new THREE.Uniform
        ({
            intensity          : 1.0,                         // overall light intensity
            shadows            : 0.0,                         // threshold for shadow casting
            color_ambient      : new THREE.Color(0xffffff),   // ambient light color
            color_diffuse      : new THREE.Color(0xffffff),   // diffuse light color
            color_specular     : new THREE.Color(0xffffff),   // specular light color
            position_offset    : new THREE.Vector3(),         // offset position for light source
        }),

        u_debug: new THREE.Uniform
        ({
            option    : 0,
            variable1 : 0,
            variable2 : 0,
            variable3 : 0,
            variable4 : 0,
            variable5 : 0,
        }),
    }

    const defines = 
    {           
        VARIATION_ENABLED: 1,
        BERNSTEIN_ENABLED: 1,
        SKIPPING_ENABLED : 1,

        MARCHING_METHOD     : 1,
        INTERPOLATION_METHOD: 2,
        SKIPPING_METHOD     : 2,
        GRADIENTS_METHOD    : 3,

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