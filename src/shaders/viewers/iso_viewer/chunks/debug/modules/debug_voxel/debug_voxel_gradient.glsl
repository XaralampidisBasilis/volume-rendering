
vec3 debug_voxel_gradient = (voxel.gradient / u_volume.max_gradient_length) * 0.5 + 0.5;

debug.voxel_gradient = vec4(debug_voxel_gradient, 1.0);
