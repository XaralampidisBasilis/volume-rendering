
// Compute block coords from trace position
block.coords = ivec3(trace.position * u_extremap.inv_spacing);

// Sample extremap map and compute block occupation
vec2 texture_extrema_sample = texelFetch(u_textures.extrema_map, block.coords, 0).rg;
block.min_value = texture_extrema_sample.r; 
block.max_value = texture_extrema_sample.g; 
block.occupied = proj_voxel.value < block.max_value;