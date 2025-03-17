import * as THREE from 'three'
import vertexShader from '@shaders/mpr_viewer/surface/vertex.glsl'
import fragmentShader from '@shaders/mpr_viewer/surface/fragment.glsl'

export default function()
{
    const uniforms = 
    {
        u_textures: new THREE.Uniform
        ({
            intensity_map  : null,
            binary_map     : null,
            distance_map   : null,
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions     : new THREE.Vector3(),
            spacing        : new THREE.Vector3(),
            size           : new THREE.Vector3(),
            inv_dimensions : new THREE.Vector3(),
            inv_spacing    : new THREE.Vector3(),
            inv_size       : new THREE.Vector3(),
            spacing_length : 0.0,
            size_length    : 0.0,
        }),

        u_bounding_box : new THREE.Uniform
        ({
            dimensions  : new THREE.Vector3(),
            min_coords  : new THREE.Vector3(),
            max_coords  : new THREE.Vector3(),
            min_position: new THREE.Vector3(),
            max_position: new THREE.Vector3(),
        }),

        u_slices : new THREE.Uniform
        ({
            hessian : new Array(3).map(() => new THREE.Vector4()),
            visible : new Array(3).map(() => true),
        }),

        u_shading: new THREE.Uniform
        ({
            ambient_reflectance  : 0.2  ,
            diffuse_reflectance  : 1.0,
            specular_reflectance : 1.0,
            shininess            : 40.0,
        }),
        
        u_debugging: new THREE.Uniform
        ({
            option      : 0,
            max_voxels  : 0,
            variable1   : 0,
            variable2   : 0,
            variable3   : 0,
        }),
    }

    const defines = 
    {           
        INTERSECT_BBOX_ENABLED  : 1,
        INTERSECT_SLICES_ENABLED: 1,
        DISCARDING_DISABLED     : 0,
        STATS_ENABLED           : 1,
        DEBUG_ENABLED           : 1,
        MAX_TRACES              : 1000,
        MAX_VOXELS              : 1000,
    }

    const material = new THREE.ShaderMaterial
    ({    
        side: THREE.BackSide,
        glslVersion: THREE.GLSL3,
        uniforms: uniforms,
        defines: defines,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
    })

    return material
}