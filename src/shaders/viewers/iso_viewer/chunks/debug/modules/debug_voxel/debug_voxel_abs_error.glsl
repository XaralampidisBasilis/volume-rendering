
vec3 debug_voxel_abs_error = mmix(BLACK_COLOR, RED_COLOR, abs(voxel.error / MILLI_TOLERANCE));

debug.voxel_abs_error = vec4(debug_voxel_abs_error, 1.0);
