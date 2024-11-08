
// Sample occumaps atlas at the current occumap level of detail

// find block coords of ray start position in current occumap
occumap.block_coords = ivec3(floor(ray.end_position * occumap.inv_spacing));

// sample the occumaps atlas and check if block is occupied
occumap.block_occupancy = texelFetch(u_textures.occumaps, occumap.start_coords + occumap.block_coords, 0).r;
occumap.block_occupied = occumap.block_occupancy > 0.0;