vec3 debug_occumap_block_coords = vec3(occumap.block_coords) / vec3(occumap.dimensions - 1);

debug.occumap_block_coords = vec4(debug_occumap_block_coords, 1.0);