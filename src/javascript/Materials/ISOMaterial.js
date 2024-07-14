import * as THREE from 'three'
import { colormapLocations } from '../../../static/textures/colormaps/colormaps.js'
import vertexShader from '../../shaders/viewers/iso_viewer/vertex.glsl'
import fragmentShader from '../../shaders/viewers/iso_viewer/fragment.glsl'

export default function()
{
    const uniforms = {
                
        u_sampler: new THREE.Uniform({
            volume:          null,
            mask:            null,
            colormap:        null,
            noise:           null,
            occupancy:       null,
        }),

        u_volume : new THREE.Uniform({

            dimensions:      new THREE.Vector3(),
            size:            new THREE.Vector3(),
            voxel:           new THREE.Vector3(),

        }),

        u_raycast: new THREE.Uniform({
            threshold:       0.2,   
            refinements:     1,   
            resolution:      1,
            stride:          3,   
            dither:          true, 
        }),

        u_gradient: new THREE.Uniform({
            resolution:      0.7,  
            method:          1,        
            neighbor:        true,
        }),
            
        u_colormap: new THREE.Uniform({
            name:            'cet_d9',
            v:               colormapLocations['cet_d9'].v,
            u_range:         new THREE.Vector2(colormapLocations['cet_d9'].u_start, colormapLocations['cet_d9'].u_end),
            u_lim:           new THREE.Vector2(0, 1),
        }),

        u_lighting: new THREE.Uniform({
            a_color:         new THREE.Color(0xffffff).multiplyScalar(0.15),    
            d_color:         new THREE.Color(0xffffff),    
            s_color:         new THREE.Color(0xffffff),      
            ka:              1,     
            kd:              1,     
            ks:              1,   
            shininess:       40,    
            power:           0.7,    
            model:           2,    
            attenuate:       false,
            levels:          10,
            edge:            0.1,
        }),

        u_occupancy: new THREE.Uniform({
            size:            new THREE.Vector3(),
            block:           new THREE.Vector3(),
            box_min:         new THREE.Vector3(0, 0, 0),
            box_max:         new THREE.Vector3(1, 1, 1),
            resolution:      2, // resolution close to 2 makes computation shader to lag
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

        // glslVersion: THREE.GLSL3,
        uniforms: uniforms,
        defines: defines,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader
    })

    return material
}