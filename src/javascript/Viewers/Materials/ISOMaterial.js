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
            volume:          null,
            gradients:       null,
            mask:            null,
            colormap:        null,
            noisemap:        null,
            occumap:         null,
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions:      new THREE.Vector3(),
            size:            new THREE.Vector3(),
            spacing:         new THREE.Vector3(),
            inv_dimensions:  new THREE.Vector3(),
            inv_size:        new THREE.Vector3(),   
            inv_spacing:     new THREE.Vector3(),
        }),

        u_raycast: new THREE.Uniform
        ({
            threshold:          0.3,   
            min_stepping:       0.3,
            max_stepping:       2,
            max_steps:          1000,
            spacing_method:     2,
            stepping_method:    1,
            dithering_method:   1,
            refinement_method:  2, 
            has_refinement:     true,
            has_dithering:      true,
            has_skipping:       false,
            has_bbox:           true, 
        }),

        u_gradient: new THREE.Uniform
        ({
            threshold:       0,
            min_norm:        0,
            max_norm:        0,
            norm_range:      0,
            method:          3,        
        }),
            
        u_colormap: new THREE.Uniform
        ({
            name:            'cet_d9',
            texture_row:      colormapLocations['cet_d9'].v,
            texture_columns:  new THREE.Vector2(colormapLocations['cet_d9'].u_start, colormapLocations['cet_d9'].u_end),
            low:              0,
            high:             1,
            levels:           255,
        }),

        u_lighting: new THREE.Uniform
        ({
            a_color:         new THREE.Color(0xffffff).multiplyScalar(0.15),    
            d_color:         new THREE.Color(0xffffff),    
            s_color:         new THREE.Color(0xffffff),      
            ka:              1,     
            kd:              1,     
            ks:              1, 
            shadows:         1,  
            shininess:       40,    
            power:           0.7,    
            model:           2,    
            attenuation:     false,
            edge_threshold:  1,
            position:        new THREE.Vector3(),
        }),

        u_occupancy: new THREE.Uniform
        ({
            occumap_dimensions: new THREE.Vector3(),
            block_dimensions:   new THREE.Vector3(),
            box_min:            new THREE.Vector3(0, 0, 0),
            box_max:            new THREE.Vector3(1, 1, 1),
            divisions:          10, 
        }),

        u_debug: new THREE.Uniform
        ({
            option:            0,
            scale:             1,
            constant:          0,
            probability:     0.5,
        })

    }

    const defines = 
    {
        STEPPING_METHOD : 1,
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