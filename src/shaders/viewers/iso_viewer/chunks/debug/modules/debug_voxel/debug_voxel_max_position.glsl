

vec3 debug_voxel_min_position = map(box.min_position, box.max_position, voxel.min_position);

debug.voxel_min_position = vec4(debug_voxel_min_position, 1.0);