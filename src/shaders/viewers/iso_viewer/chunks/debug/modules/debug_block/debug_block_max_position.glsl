

vec3 debug_block_max_position = map(box.min_position, box.max_position, block.max_position);

debug.block_max_position = vec4(debug_block_max_position, 1.0);