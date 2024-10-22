
vec3 debug_block_min_position = block.min_position / u_occupancy.base_size;

debug.block_min_position = vec4(debug_block_min_position, 1.0);
