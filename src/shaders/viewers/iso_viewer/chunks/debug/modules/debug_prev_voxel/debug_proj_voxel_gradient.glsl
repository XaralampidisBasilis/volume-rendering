
vec3 debug_proj_voxel_gradient = (proj_voxel.gradient / u_volume.max_gradient_length) * 0.5 + 0.5;

debug.proj_voxel_gradient = vec4(debug_proj_voxel_gradient, 1.0);
