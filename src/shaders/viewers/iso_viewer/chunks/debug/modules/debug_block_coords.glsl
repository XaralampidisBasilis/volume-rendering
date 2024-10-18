
vec3 block_occumap_dims = vec3(textureSize(u_sampler.occumap, block.lod).xyz);
vec3 block_coords = vec3(block.coords) / (block_occumap_dims - 1.0);

debug.block_coords = vec4(vec3(block_coords), 1.0);