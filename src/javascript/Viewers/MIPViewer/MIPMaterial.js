import * as THREE from 'three'
import { colormapLocations } from '../../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../../shaders/viewers/mip_viewer/vertex.glsl'
import fragmentShader from '../../../shaders/viewers/mip_viewer/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        u_textures: new THREE.Uniform({
            volume    : null,
            mask      : null,
            occumaps  : null,
            colormaps : null,
            noisemap  : null,
        }),

        u_volume : new THREE.Uniform({
            dimensions            : new THREE.Vector3(),
            size                  : new THREE.Vector3(),
            spacing               : new THREE.Vector3(),
            size_length           : 0.0,
            spacing_length        : 0.0,
            inv_dimensions        : new THREE.Vector3(),
            inv_size              : new THREE.Vector3(),
            inv_spacing           : new THREE.Vector3(),
            inv_size_length       : 0.0,
            inv_spacing_length    : 0.0,

            min_coords            : new THREE.Vector3(),
            max_coords            : new THREE.Vector3(),
            min_position          : new THREE.Vector3(),
            max_position          : new THREE.Vector3(),
            min_gradient          : new THREE.Vector3(),
            max_gradient          : new THREE.Vector3(),
            max_gradient_magnitude: 0.0,
        }),

        u_mask : new THREE.Uniform({
            dimensions    : new THREE.Vector3(),
            size          : new THREE.Vector3(),
            spacing       : new THREE.Vector3(),
            inv_dimensions: new THREE.Vector3(),
            inv_size      : new THREE.Vector3(),
            inv_spacing   : new THREE.Vector3(),
        }),

        u_occumaps: new THREE.Uniform
        ({
            lods           : 0,
            dimensions     : new THREE.Vector3(),
            inv_dimensions : new THREE.Vector3(),
            base_dimensions: new THREE.Vector3(),
            base_spacing   : new THREE.Vector3(),
            base_size      : new THREE.Vector3(),
        }),

        u_colormap: new THREE.Uniform({
            levels      : 255,
            name        : 'viridis',
            thresholds  : new THREE.Vector2(0, 1),
            start_coords: new THREE.Vector2(colormapLocations['viridis'].x_start, colormapLocations['viridis'].y),
            end_coords  : new THREE.Vector2(colormapLocations['viridis'].x_end,   colormapLocations['viridis'].y),
        }),

        u_raymarch: new THREE.Uniform({
            min_sample_value  : 0,
            max_sample_value  : 1,
            step_speed        : 1.0 / 255,
            min_step_scaling  : 1,
            max_step_scaling  : 1,
            max_step_count    : 1000,
            max_skip_count    : 500,
            min_skip_lod      : 0,
            max_skip_lod      : 0,
        }),

        u_debugger: new THREE.Uniform({
            option    : 0,
            variable1 : 0,
            variable2 : 0,
            variable3 : 0,
        }),
    }

    const defines = 
    {
        VOLUME_GRADIENTS_METHOD          : 1,
        VOLUME_SMOOTHING_METHOD          : 1,
        VOLUME_SMOOTHING_RADIUS          : 0,
        RAY_BVH_INTERSECTION_ENABLED     : 0,
        RAY_DITHERING_ENABLED            : 0,
        TRACE_ADAPTIVE_STEP_ENABLED      : 0,
        TRACE_BVH_MARCHING_ENABLED       : 0,
        TRACE_POSITION_REFINEMENT_ENABLED: 0,
        FRAGMENT_DISCARDING_DISABLED     : 0,
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