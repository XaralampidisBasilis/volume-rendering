
// Sample occumaps atlas at the current occumap level of detail

// find block coords of ray start position in current occumap
block_coords = ivec3(floor(ray.start_position * occumap.inv_spacing));

// convert occumap coords to atlas coords by adding the offset
ivec3 occumaps_coords = occumap.start_coords + block_coords;

// sample the occumaps atlas and check if block is occupied
float block_occupancy = texelFetch(textures.occumaps, occumaps_coords, 0).r;
block_occupied = block_occupancy > 0.0;