import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/viewers/iso_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/viewers/iso_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        textures: new THREE.Uniform({
            volume    : null,
            mask      : null,
            occumaps  : null,
            colormaps : null,
            noisemap  : null,
        }),

        volume : new THREE.Uniform({
            dimensions            : new THREE.Vector3(),
            size                  : new THREE.Vector3(),
            spacing               : new THREE.Vector3(),
            inv_dimensions        : new THREE.Vector3(),
            inv_size              : new THREE.Vector3(),
            inv_spacing           : new THREE.Vector3(),
            min_coords            : new THREE.Vector3(),
            max_coords            : new THREE.Vector3(),
            min_position          : new THREE.Vector3(),
            max_position          : new THREE.Vector3(),
            min_gradient          : new THREE.Vector3(),
            max_gradient          : new THREE.Vector3(),
            max_gradient_magnitude: 0.0,
        }),

        mask : new THREE.Uniform({
            dimensions    : new THREE.Vector3(),
            size          : new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            inv_size      : new THREE.Vector3(),
            inv_spacing   : new THREE.Vector3(),
        }),

        occumaps: new THREE.Uniform
        ({
            atlas_lods       : 0,
            atlas_dimensions : new THREE.Vector3(),
            base_dimensions  : new THREE.Vector3(),
            base_spacing     : new THREE.Vector3(),
            base_size        : new THREE.Vector3(),
        }),

        colormap: new THREE.Uniform({
            levels      : 255,
            name        : 'cet_d9',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['cet_d9'].x_start, colormapLocations['cet_d9'].y),
            end_coords  : new THREE.Vector2(colormapLocations['cet_d9'].x_end,   colormapLocations['cet_d9'].y),
        }),

        shading: new THREE.Uniform({
            ambient_reflectance  : 0.2,
            diffuse_reflectance  : 1.0,
            specular_reflectance : 1.0,
            shininess            : 40.0,
            edge_contrast        : 0.0,
        }),
        
        lighting: new THREE.Uniform({
            intensity          : 1.0,                         // overall light intensity
            shadows            : 0.0,                         // threshold for shadow casting
            ambient_color      : new THREE.Color(0xffffff),   // ambient light color
            diffuse_color      : new THREE.Color(0xffffff),   // diffuse light color
            specular_color     : new THREE.Color(0xffffff),   // specular light color
            position_offset    : new THREE.Vector3(),         // offset position for light source
        }),

        raymarch: new THREE.Uniform({
            sample_threshold   : 0.3,
            gradient_threshold : 0.0,
            min_step_scale     : 1.0,
            max_step_scale     : 1.0,
            max_step_count     : 1000,
            max_skip_count     : 200,
            min_skip_lod       : 0,
        }),

        debug: new THREE.Uniform({
            option : 0,
        }),
    }

    const defines = 
    {
        VOLUME_GRADIENTS_METHOD : 1,
        VOLUME_SMOOTHING_METHOD : 1,
        VOLUME_SMOOTHING_RADIUS : 2,
 
        RAY_DITHERING_ENABLED     : 1,
        RAY_DITHERING_METHOD      : 1,
        RAY_STEPPING_METHOD       : 1,
        RAY_REFINEMENT_ENABLED    : 1,
        RAY_REFINEMENT_METHOD     : 2,
        RAY_GRADIENTS_ENABLED     : 1,
        RAY_GRADIENTS_METHOD      : 1,
        RAY_SMOOTHING_ENABLED     : 1,
        RAY_SMOOTHING_METHOD      : 1,
        RAY_SKIPPING_BBOX_ENABLED : 1,
        RAY_SKIPPING_BLOCK_ENABLED: 1,

        TRACE_DITHERING_ENABLED     : 0,
        TRACE_DITHERING_METHOD      : 1,
        TRACE_SCALING_METHOD        : 10,
        TRACE_DERIVATIVES_METHOD    : 1,
        TRACE_SKIPPING_BLOCK_ENABLED: 1,

        LIGHTING_ATTENUATION_ENABLED : 0,
        LIGHTING_ATTENUATION_METHOD  : 0,

        SHADING_METHOD: 0,

        DEBUG_DISCARDING_ENABLED : 1,
    }

    const material = new THREE.ShaderMaterial({
        
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