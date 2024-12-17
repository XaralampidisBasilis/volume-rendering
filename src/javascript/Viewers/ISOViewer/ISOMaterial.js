import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/viewers/iso_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/viewers/iso_viewer/fragment.glsl'

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
            min_position          : new THREE.Vector3(),
            max_position          : new THREE.Vector3(),
            min_gradient          : new THREE.Vector3(),
            max_gradient          : new THREE.Vector3(),
            max_gradient_length   : 0.0,
        }),

        u_distmap : new THREE.Uniform
        ({
            max_distance    : 0,
            sub_division    : 2,
            dimensions      : new THREE.Vector3(),
            spacing         : new THREE.Vector3(),
            size            : new THREE.Vector3(),
            inv_sub_division: 0.0,
            inv_dimensions  : new THREE.Vector3(),
            inv_spacing     : new THREE.Vector3(),
            inv_size        : new THREE.Vector3(),
        }),

        u_rendering: new THREE.Uniform
        ({
            threshold_value  : 0.3,
            min_step_scaling : 0.1,
            max_step_scaling : 2.0,
            max_step_count   : 1000,
            max_skip_count   : 200,
        }),

        u_colormap: new THREE.Uniform
        ({
            levels      : 255,
            name        : 'cet_d9',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['cet_d9'].x_start, colormapLocations['cet_d9'].y),
            end_coords  : new THREE.Vector2(colormapLocations['cet_d9'].x_end,   colormapLocations['cet_d9'].y),
        }),

        u_shading: new THREE.Uniform
        ({
            ambient_reflectance  : 0.2,
            diffuse_reflectance  : 1.0,
            specular_reflectance : 1.0,
            shininess            : 40.0,
            edge_contrast        : 0.0,
        }),
        
        u_lighting: new THREE.Uniform
        ({
            intensity          : 1.0,                         // overall light intensity
            shadows            : 0.0,                         // threshold for shadow casting
            ambient_color      : new THREE.Color(0xffffff),   // ambient light color
            diffuse_color      : new THREE.Color(0xffffff),   // diffuse light color
            specular_color     : new THREE.Color(0xffffff),   // specular light color
            position_offset    : new THREE.Vector3(),         // offset position for light source
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
        INTERSECT_BBOX_ENABLED     : 1,
        INTERSECT_BVOL_ENABLED     : 1,
        REFINE_INTERSECTION_ENABLED: 1,
        REFINE_GRADIENTS_ENABLED   : 1,
        SKIPPING_ENABLED           : 1,
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