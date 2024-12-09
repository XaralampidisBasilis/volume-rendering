// Compute block coords from ray end position
block.coords = ivec3(trace.position * u_distmap.inv_spacing);

// Sample the distance map and compute if block is occupied
block.value = int(texelFetch(u_textures.distmap, block.coords, 0).r * 255.0);
block.occupied = block.value <= 0;
