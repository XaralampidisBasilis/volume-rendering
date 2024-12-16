
vec3 debug_voxel_error = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, voxel.error / MILLI_TOLERANCE));

debug.voxel_error = vec4(debug_voxel_error, 1.0);
