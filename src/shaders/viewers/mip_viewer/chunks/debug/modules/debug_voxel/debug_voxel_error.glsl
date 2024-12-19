
vec3 debug_voxel_error = mmix(RED_COLOR, BLACK_COLOR, WHITE_COLOR, map(ray.min_value, ray.max_value, voxel.value));

debug.voxel_error = vec4(debug_voxel_error, 1.0);
