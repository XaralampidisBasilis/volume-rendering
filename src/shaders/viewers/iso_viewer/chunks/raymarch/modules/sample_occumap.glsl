
trace.block_coords = ivec3(trace.position / occumap.spacing);

// convert occumap coords to atlas coords and sample the atlas
ivec3 occumaps_coords = occumap.start_coords + trace.block_coords;
trace.block_occupied = texelFetch(textures.occumaps, occumaps_coords, 0).r > 0.0;
