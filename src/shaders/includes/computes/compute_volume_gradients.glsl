
precision highp int;
precision highp float;
precision highp sampler3D; 

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coords = ivec2(gl_FragCoord.xy); // in range [0, X-1][0, Y*Z-1]
    ivec3 voxel_coords = reshape_2d_to_3d(pixel_coords, u_computation.volume_dimensions); // in range [0, X-1][0, Y-1][0, Z-1]

    // gl_FragColor = vec4(vec2(pixel_coords)/vec2(u_computation.computation_dimensions-1), 1.0, 1.0);
    // gl_FragColor = vec4(vec3(voxel_coords)/vec3(u_computation.volume_dimensions-1), 1.0);

    
}
