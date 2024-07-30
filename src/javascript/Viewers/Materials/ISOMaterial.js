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
            mask:            null,
            colormap:        null,
            noise:           null,
            occumaps:        new Array(3),
        }),

        u_volume : new THREE.Uniform
        ({
            dimensions:      new THREE.Vector3(),
            size:            new THREE.Vector3(),
            spacing:         new THREE.Vector3(),
        }),

        u_raycast: new THREE.Uniform
        ({
            threshold:       0.2,   
            refinements:     0,   
            resolution_min:  1,
            resolution_max:  1,
            step_method:     3,
            dither_method:   2,
            dithering:       true, 
            skipping:        false,
        }),

        u_gradient: new THREE.Uniform
        ({
            threshold:       0,
            resolution:      1,  
            method:          3,        
            max_sampling:    false,
        }),
            
        u_colormap: new THREE.Uniform
        ({
            name:            'cet_d9',
            texture_id:      colormapLocations['cet_d9'].v,
            texture_range:   new THREE.Vector2(colormapLocations['cet_d9'].u_start, colormapLocations['cet_d9'].u_end),
            low:             0,
            high:            1,
            levels:          255,
        }),

        u_lighting: new THREE.Uniform
        ({
            a_color:         new THREE.Color(0xffffff).multiplyScalar(0.15),    
            d_color:         new THREE.Color(0xffffff),    
            s_color:         new THREE.Color(0xffffff),      
            ka:              1,     
            kd:              1,     
            ks:              1,   
            shininess:       40,    
            power:           0.7,    
            model:           2,    
            attenuation:     false,
            edge_threshold:  1,
            position:        new THREE.Vector3(),
        }),

        u_occupancy: new THREE.Uniform
        ({
            dimensions:      new Array(3).fill().map(() => new THREE.Vector3()),
            blocks:          new Array(3).fill().map(() => new THREE.Vector3()),
            box_min:         new THREE.Vector3(0, 0, 0),
            box_max:         new THREE.Vector3(1, 1, 1),
            divisions:       10, // divisions close to 2 makes computation shader to lag
            method:          1,
        })

    }

    const defines = {

    }

    const material = new THREE.ShaderMaterial({
        
        side: THREE.BackSide,
        transparent: false,
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