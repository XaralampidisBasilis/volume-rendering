
vec3 block_coords = trace.position / occumap.spacing;

// find block coords in current occumap
trace.block_coords = ivec3(floor(block_coords));
// trace.block_texture_coords = block_coords * occumaps.inv_dimensions;

// convert occumap coords to atlas coords and sample the atlas
ivec3 occumaps_coords = occumap.start_coords + trace.block_coords;
// vec3 occumaps_texture_coords = occumap.start_texture_coords + trace.block_texture_coords;

// trace.block_occupancy = textureLod(textures.occumaps, occumaps_texture_coords, 0.0).r;
trace.block_occupancy = texelFetch(textures.occumaps, occumaps_coords, 0).r;
trace.block_occupied = trace.block_occupancy > 0.0;
