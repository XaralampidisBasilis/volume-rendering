
float debug_voxel_gradient_length = map(0.0, u_volume.max_gradient_length, length(voxel.gradient));

debug.voxel_gradient_length = vec4(vec3(debug_voxel_gradient_length), 1.0);
