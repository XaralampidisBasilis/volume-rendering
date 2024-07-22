
precision highp int;
precision highp float;
precision highp sampler3D; 

#include "./modules/smooth_gaussian"

struct uniforms_computation 
{
    sampler3D volume_data;
    vec3 volume_size;
    vec3 volume_spacing;
    vec3 volume_dimensions;  
    vec2 computation_dimensions;  
};
uniform uniforms_computation u_computation;

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    vec2 pixel_coords = vec2(gl_FragCoord.xy); // in range [0, X-1][0, Y*Z-1]
    vec3 voxel_coords = reshape_2d_to_3d(pixel_coords, u_computation.volume_dimensions); // in range [0, X-1][0, Y-1][0, Z-1]

    // gl_FragColor = vec4(pixel_coords/u_computation.computation_dimensions-1, 1.0, 1.0);
    // gl_FragColor = vec4(voxel_coords/u_computation.volume_dimensions-1, 1.0);

    float smooth_sample smooth_gaussian26(u_computation.volume_data, u_computation.volume_size, u_computation.volume_spacing, voxel_coords);
    
    gl_FragColor = vec4(vec3(smooth_sample), 1.0);
}
