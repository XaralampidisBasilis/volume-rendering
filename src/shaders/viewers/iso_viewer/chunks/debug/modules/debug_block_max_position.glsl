

vec3 block_max_position = block.max_position / u_occupancy.occumap_size;

debug.block_max_position = vec4(block_max_position, 1.0);
