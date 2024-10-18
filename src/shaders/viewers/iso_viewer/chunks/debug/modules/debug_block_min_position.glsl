
vec3 block_min_position = block.min_position / u_occupancy.occumap_size;

debug.block_min_position = vec4(block_min_position, 1.0);
