
vec3 debug_block_coords = vec3(block.coords) / vec3(occumap.dimensions - 1);

debug.block_coords = vec4(vec3(debug_block_coords), 1.0);