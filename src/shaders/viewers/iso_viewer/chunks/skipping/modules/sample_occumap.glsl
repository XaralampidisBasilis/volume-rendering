
// find block coords
trace.block_coords = ivec3(trace.position / occumap.spacing);

// sample block occupancy 
ivec3 occumaps_coords = occumap.start_coords + trace.block_coords;
trace.block_occupied = texelFetch(u_sampler.occumaps, occumaps_coords, 0).r > 0.0;
