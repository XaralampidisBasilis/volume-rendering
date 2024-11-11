
// Sample occumaps atlas at the current occumap level of detail
vec3 block_coords = ray.start_position * occumap.inv_spacing;

// find block coords of ray start position in current occumap
occumap.block_coords = ivec3(floor(block_coords));
occumap.block_texture_coords = block_coords * u_occumaps.inv_dimensions;

// compute occumaps atlas coordinates for current occumap level of detail
ivec3 occumaps_coords = occumap.start_coords + occumap.block_coords;
vec3 occumaps_texture_coords = occumap.start_texture_coords + occumap.block_texture_coords;

// sample the occumaps atlas and check if block is occupied
// occumap.block_occupancy = texelFetch(u_textures.occumaps, occumaps_coords, 0).r;
occumap.block_occupancy = textureLod(u_textures.occumaps, occumaps_texture_coords, 0.0).r;
occumap.block_occupied = occumap.block_occupancy > 0.0;