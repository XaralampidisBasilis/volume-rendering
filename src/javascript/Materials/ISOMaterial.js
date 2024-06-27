import * as THREE from 'three'
import { colormaps } from '../../../static/textures/colormaps/colormaps'

import vertexShader from '../../shaders/viewers/iso/vertex.glsl'
import fragmentShader from '../../shaders/viewers/iso/fragment.glsl'


export default function()
{
    const uniforms = {
        
        u_mask_data:                new THREE.Uniform(),   
        u_noisemap_data:            new THREE.Uniform(),   
        
        u_volume_size:              new THREE.Uniform(new THREE.Vector3()),
        u_volume_voxel:             new THREE.Uniform(new THREE.Vector3()),
        u_volume_data:              new THREE.Uniform(),
        
        u_raycast_threshold:        new THREE.Uniform(0),   
        u_raycast_refinements:      new THREE.Uniform(1),   
        u_raycast_resolution:       new THREE.Uniform(1),   
        u_raycast_dithering:        new THREE.Uniform(true),   
        
        u_gradient_method:          new THREE.Uniform(1),      
        u_gradient_resolution:      new THREE.Uniform(0.7),      
            
        u_colormap_data:            new THREE.Uniform(),
        u_colormap_name:            new THREE.Uniform('cet_d9'),
        u_colormap_v:               new THREE.Uniform(colormaps['cet_d9'].v),
        u_colormap_u_range:         new THREE.Uniform(new THREE.Vector2(colormaps['cet_d9'].u_start, colormaps['cet_d9'].u_end)),
        u_colormap_u_lim:           new THREE.Uniform(new THREE.Vector2(0, 1)),
        
        u_lighting_attenuation:     new THREE.Uniform(false),
        u_lighting_shininess:       new THREE.Uniform(40),    
        u_lighting_power:           new THREE.Uniform(0.7),    
        u_lighting_mode:            new THREE.Uniform(2),    
        u_lighting_a_color:         new THREE.Uniform(new THREE.Color(0xffffff).multiplyScalar(0.15)),    
        u_lighting_d_color:         new THREE.Uniform(new THREE.Color(0xffffff)),    
        u_lighting_s_color:         new THREE.Uniform(new THREE.Color(0xffffff)),      
        u_lighting_ka:              new THREE.Uniform(1),     
        u_lighting_kd:              new THREE.Uniform(1),     
        u_lighting_ks:              new THREE.Uniform(1),     
        
        u_occupancy_data:           new THREE.Uniform(),
        u_occupancy_size:           new THREE.Uniform(new THREE.Vector3()),
        u_occupancy_block:          new THREE.Uniform(new THREE.Vector3()),
        u_occupancy_box_min:        new THREE.Uniform(new THREE.Vector3(0, 0, 0)),
        u_occupancy_box_max:        new THREE.Uniform(new THREE.Vector3(1, 1, 1)),
        u_occupancy_resolution:     new THREE.Uniform(24),
  
    }

    const defines = {

        // u_lighting_a_color:     new THREE.Uniform(new THREE.Color(0xffffff).multiplyScalar(0.15)),    
        // u_lighting_d_color:     new THREE.Uniform(new THREE.Color(0xffffff)),    
        // u_lighting_s_color:     new THREE.Uniform(new THREE.Color(0xffffff)), 

    }

    const material = new THREE.ShaderMaterial({
        side: THREE.BackSide,
        transparent: false,
        depthTest: true,
        depthWrite: false,
        uniforms: uniforms,
        defines: defines,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader
    })

    return material
}