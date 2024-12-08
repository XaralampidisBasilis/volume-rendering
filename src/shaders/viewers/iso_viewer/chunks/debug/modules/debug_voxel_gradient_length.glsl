
float debug_voxel_gradient_length = (length(voxel.gradient) / u_volume.max_gradient_length) * 0.5 + 0.5;

debug.voxel_gradient_length = vec4(vec3(debug_voxel_gradient_length), 1.0);
