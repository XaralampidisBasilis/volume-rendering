
precision highp int;
precision highp float;
precision highp sampler3D; 

#include "../../utils/inside_texture"
#include "../../utils/reshape_coordinates"
#include "./modules/gradient_sobel26"

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

    // gl_FragColor = vec4(vec2(pixel_coords)/vec2(computation_dimensions-1), 1.0, 1.0);
    // gl_FragColor = vec4(vec3(voxel_coords)/vec3(volume_dimensions-1), 1.0);

    float voxel_sample = 0.0;
    vec3 gradient_vector = gradient_sobel26(volume_data, volume_size, volume_spacing, volume_dimensions, voxel_coords, voxel_sample);
    
    // normalize gradient vector in range [0, 1], from [-1, 1]
    gradient_vector = (0.5 * gradient_vector) + 0.5;

    gl_FragColor = vec4(gradient_vector, voxel_sample);

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
