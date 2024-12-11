import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/viewers/mip_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/viewers/mip_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        u_textures: new THREE.Uniform
        ({
            taylor_map: null,
            distance_map  : null,
            color_maps: null,
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions            : new THREE.Vector3(),
            spacing               : new THREE.Vector3(),
            size                  : new THREE.Vector3(),
            spacing_length        : 0.0,
            size_length           : 0.0,
            inv_dimensions        : new THREE.Vector3(),
            inv_spacing           : new THREE.Vector3(),
            inv_size              : new THREE.Vector3(),
            min_gradient          : new THREE.Vector3(),
            max_gradient          : new THREE.Vector3(),
            max_gradient_length   : 0.0,
        }),

        u_distmap : new THREE.Uniform
        ({
            max_distance  : 0,
            sub_division  : 3,
            dimensions    : new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            size          : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            inv_spacing   : new THREE.Vector3(),
            inv_size      : new THREE.Vector3(),
        }),

        u_rendering: new THREE.Uniform
        ({
            min_value        : 0,
            min_step_scaling : 1,
            max_step_scaling : 5,
            max_step_count   : 1000,
            max_skip_count   : 200,
        }),

        u_colormap: new THREE.Uniform
        ({
            levels      : 255,
            name        : 'viridis',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['viridis'].x_start, colormapLocations['viridis'].y),
            end_coords  : new THREE.Vector2(colormapLocations['viridis'].x_end,   colormapLocations['viridis'].y),
        }),

        u_shading: new THREE.Uniform
        ({
            shininess            : 40.0,
            edge_contrast        : 0.0,
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
        INTERSECT_BVOL_ENABLED     : 0,
        REFINE_INTERSECTION_ENABLED: 0,
        SKIPPING_ENABLED           : 0,
        DITHERING_ENABLED          : 0,
        DISCARDING_DISABLED        : 0,
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