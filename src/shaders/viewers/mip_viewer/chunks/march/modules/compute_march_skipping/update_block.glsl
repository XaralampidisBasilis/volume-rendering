// Compute block coords from trace position
block.coords = ivec3(trace.position * u_distmap.inv_spacing);

// Sample the distance map and compute if block is occupied
block.value = int(texelFetch(u_textures.distance_map, block.coords, 0).r * 255.0);
block.occupied = block.value <= 0;
