
precision highp int;
precision highp float;
precision highp sampler3D; 

#include "../../utils/sum"
#include "../../utils/mmin"
#include "../../utils/inside"
#include "../../utils/outside"
#include "../../utils/inside_box"
#include "../../utils/reshape"

uniform sampler3D volume_data;
uniform int volume_count;
uniform vec3 volume_size;
uniform ivec3 volume_dimensions;  
uniform vec3 volume_inv_dimensions;  
uniform vec3 volume_inv_spacing;  
uniform ivec2 computation_dimensions; 

void main()
{
    // compute pixel coordinates and index
    ivec2 pixel_coords = ivec2(gl_FragCoord.xy); 
    int pixel_index = reshape_2d_to_1d(pixel_coords, computation_dimensions); 

    // convert pixel coordinates to voxel coordinates
    ivec3 voxel_coords = reshape_1d_to_3d(pixel_index, volume_dimensions); 
    // float is_volume = float(pixel_index < volume_count);

    // compute gradients and assign color data
    #include "./compute_gradient"

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>

   /** debug
    * gl_FragColor = vec4(vec2(pixel_coords)/vec2(computation_dimensions - 1), 0.0, 1.0);
    * gl_FragColor = vec4(vec3(float(pixel_index)/float(volume_count - 1)), 1.0);
    * gl_FragColor = vec4(vec3(voxel_coords.x)/vec3(volume_dimensions.x-1), 1.0);
    * gl_FragColor = vec4(vec3(1.0 - inside_texture(vec3(voxel_coords) / vec3(volume_dimensions - 1))), 1.0);
    * gl_FragColor = vec4(vec3(1.0 - float(pixel_index < volume_count)), 1.0);
    * float smooth_sample = texelFetch(volume_data, voxel_coords, 0).r; 
    */
}
