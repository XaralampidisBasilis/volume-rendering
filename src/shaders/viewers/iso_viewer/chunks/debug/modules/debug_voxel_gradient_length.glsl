
float debug_voxel_gradient_length = map(-1.0, 1.0, length(voxel.gradient) / u_volume.max_gradient_length);

debug.voxel_gradient_length = vec4(vec3(debug_voxel_gradient_length), 1.0);
