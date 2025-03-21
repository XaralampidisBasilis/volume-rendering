import * as THREE from 'three'
import { colormapLocations } from '@textures/colormaps/colormaps.js'
import vertexShader from '@shaders/mpr_viewer/slice/vertex.glsl'
import fragmentShader from '@shaders/mpr_viewer/slice/fragment.glsl'

export default function()
{
    const uniforms = 
    {

        u_slice : new THREE.Uniform
        ({
            matrix : new THREE.Matrix4(),
            hessian : new THREE.Vector4(),
            visible : true,
        }),

        u_textures: new THREE.Uniform
        ({
            intensity_map  : null,
            binary_map     : null,
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions            : new THREE.Vector3(),
            spacing               : new THREE.Vector3(),
            size                  : new THREE.Vector3(),
            inv_dimensions        : new THREE.Vector3(),
            inv_spacing           : new THREE.Vector3(),
            inv_size              : new THREE.Vector3(),
            spacing_length        : 0.0,
            size_length           : 0.0,
        }),

        u_debugging: new THREE.Uniform
        ({
            option      : 0,
            variable1   : 0,
            variable2   : 0,
            variable3   : 0,
        }),
    }

    const defines = 
    {           
        INTERSECT_BBOX_ENABLED : 1,
        STATS_ENABLED          : 1,
        DEBUG_ENABLED          : 1,
        DISCARDING_DISABLED    : 0,
    }

    const material = new THREE.ShaderMaterial
    ({    
        side: THREE.DoubleSide,
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