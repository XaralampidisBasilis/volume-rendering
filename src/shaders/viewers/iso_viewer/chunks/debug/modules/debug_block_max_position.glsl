

vec3 debug_block_max_position = block.max_position / u_occupancy.base_size;

debug.block_max_position = vec4(debug_block_max_position, 1.0);
