
float debug_block_skips = float(block.skips) / float(u_occupancy.max_skips);

debug.block_skips = vec4(vec3(debug_block_skips), 1.0);