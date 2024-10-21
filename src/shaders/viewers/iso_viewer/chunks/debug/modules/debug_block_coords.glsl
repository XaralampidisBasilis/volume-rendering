
int debug_occumap_downscale = int(exp2(float(block.lod)));
ivec3 debug_occumap_dims = u_occupancy.base_dimensions / debug_occumap_downscale;
vec3 debug_block_coords = vec3(block.coords) / vec3(debug_occumap_dims - 1);

debug.block_coords = vec4(vec3(debug_block_coords), 1.0);