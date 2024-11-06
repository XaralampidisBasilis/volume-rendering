
// find block coords of trace position in current occumap
occumap.block_coords = ivec3(floor(trace.position / occumap.spacing));

// sample the occumaps atlas and check if block is occupied
occumap.block_occupancy = texelFetch(textures.occumaps, occumap.start_coords + occumap.block_coords, 0).r;
occumap.block_occupied = occumap.block_occupancy > 0.0;