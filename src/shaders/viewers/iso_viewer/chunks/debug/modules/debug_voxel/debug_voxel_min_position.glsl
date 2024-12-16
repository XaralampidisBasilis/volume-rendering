

vec3 debug_voxel_max_position = map(box.min_position, box.max_position, voxel.max_position);

debug.voxel_max_position = vec4(debug_voxel_max_position, 1.0);