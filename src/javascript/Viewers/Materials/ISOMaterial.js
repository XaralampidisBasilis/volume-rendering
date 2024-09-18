import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/viewers/iso_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/viewers/iso_viewer/fragment.glsl'

export default function(viewer)
{
    const uniforms = 
    {
        u_sampler: new THREE.Uniform
        ({
            volume   : null,
            gradients: null,
            mask     : null,
            colormap : null,
            noisemap : null,
            occumap  : null,
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions    : new THREE.Vector3(),
            size          : new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            inv_size      : new THREE.Vector3(),
            inv_spacing   : new THREE.Vector3(),
        }),

        u_raycast: new THREE.Uniform
        ({
            threshold        : 0.3,
            min_stepping     : 0.3,
            max_stepping     : 2,
            max_steps        : 1000,
            spacing_method   : 2,
            stepping_method  : 1,
            dithering_method : 1,
            refinement_method: 2,
            has_refinement   : true,
            has_dithering    : true,
            has_skipping     : false,
            has_bbox         : true,
        }),

        u_gradient: new THREE.Uniform
        ({
            threshold : 0,
            max_norm  : 0,
            method    : 3,
        }),
            
        u_colormap: new THREE.Uniform
        ({
            name           : 'cet_d9',
            texture_row    : colormapLocations['cet_d9'].v,
            texture_columns: new THREE.Vector2(colormapLocations['cet_d9'].u_start, colormapLocations['cet_d9'].u_end),
            low            : 0,
            high           : 1,
            levels         : 255,
        }),

        u_shading: new THREE.Uniform
        ({
            reflectance_a   : 0.2,
            reflectance_d   : 1,
            reflectance_s   : 1,
            shininess       : 40,
            shadow_threshold: 0,
            edge_threshold  : 0,
            model           : 2,
            attenuation     : false,
        }),

        u_lighting: new THREE.Uniform
        ({
            power          : 1.0,
            color_a        : new THREE.Color(0xffffff),
            color_d        : new THREE.Color(0xffffff),
            color_s        : new THREE.Color(0xffffff),
            offset_position: new THREE.Vector3(),
        }),

        u_occupancy: new THREE.Uniform
        ({
            occumap_dimensions: new THREE.Vector3(),
            block_dimensions  : new THREE.Vector3(),
            box_min           : new THREE.Vector3(0, 0, 0),
            box_max           : new THREE.Vector3(1, 1, 1),
            divisions         : 10,
        }),

        u_debug: new THREE.Uniform
        ({
            option     : 0,
            scale      : 1,
            constant   : 0,
            probability: 0.5,
        })

    }

    const defines = 
    {
        HAS_DITHERING      : 1,
        HAS_REFINEMENT     : 1,
        HAS_BBOX           : 1,
        HAS_SKIPPING       : 0,
        GRADIENT_METHOD    : 7,
        DITHERING_METHOD   : 1,
        SPACING_METHOD     : 2,
        STEPPING_METHOD    : 1,
        REFINEMENT_METHOD  : 2,
        SHADING_METHOD     : 1,
        ATTENUATION_METHOD : 1,
    }

    const material = new THREE.ShaderMaterial({
        
        side: THREE.BackSide,
        transparent: true,
        depthTest: true,
        depthWrite: true,

        glslVersion: THREE.GLSL1,
        uniforms: uniforms,
        defines: defines,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
    })

    return material
}