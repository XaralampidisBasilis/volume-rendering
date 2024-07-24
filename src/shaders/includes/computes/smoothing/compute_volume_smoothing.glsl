
precision highp int;
precision highp float;
precision highp sampler3D; 

#include "../../utils/reshape_coordinates"
#include "../../utils/inside_texture"
#include "../../utils/product"
#include "./modules/smoothing_gaussian27"

uniform sampler3D volume_data;
uniform vec3 volume_size;
uniform vec3 volume_spacing;
uniform vec3 volume_dimensions;  
uniform vec2 computation_dimensions; 

void main()
{
   // get 2D pixel position of occlusion man and convert it to 3D position
    vec2 pixel_coords = floor(gl_FragCoord.xy); 
    float pixel_index = reshape_2d_to_1d(pixel_coords, computation_dimensions); 
    vec3 voxel_coords = reshape_1d_to_3d(pixel_index, volume_dimensions); 

    // gl_FragColor = vec4(vec2(pixel_coords)/vec2(computation_dimensions-1.0), 0.0, 1.0);
    // gl_FragColor = vec4(vec3(pixel_index/(product(computation_dimensions) - 1.0)), 1.0);
    // gl_FragColor = vec4(vec3(voxel_coords)/vec3(volume_dimensions-1.0), 1.0);
    // gl_FragColor = vec4(vec3(1.0 - inside_texture(voxel_coords / (volume_dimensions-1.0))), 1.0);
    // gl_FragColor = vec4(vec3(1.0 - float(pixel_index < (product(volume_dimensions) - 1.0))), 1.0);
    // return;

    // float smooth_sample = smoothing_gaussian27(volume_data, volume_size, volume_spacing, volume_dimensions, voxel_coords);
    float smooth_sample = texture(volume_data, (voxel_coords + 0.5) / volume_dimensions).r;

    gl_FragColor = vec4(vec3(smooth_sample), 1.0);
}
