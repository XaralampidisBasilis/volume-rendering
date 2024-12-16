
float debug_proj_voxel_gradient_length = map(0.0, u_volume.max_gradient_length, length(proj_voxel.gradient));

debug.proj_voxel_gradient_length = vec4(vec3(debug_proj_voxel_gradient_length), 1.0);
