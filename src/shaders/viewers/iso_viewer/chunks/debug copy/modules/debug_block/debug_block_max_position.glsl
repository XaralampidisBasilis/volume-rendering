

vec3 debug_block_min_position = map(box.min_position, box.max_position, block.min_position);

debug.block_min_position = vec4(debug_block_min_position, 1.0);