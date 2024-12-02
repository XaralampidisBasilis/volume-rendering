
// Compute block coords from ray start position
block.coords = ivec3(ray.start_position * u_distmap.inv_spacing);

// Sample the distance map and compute if block is occupied
block.value = int(255.0 * texelFetch(u_textures.distmap, block.coords, 0).r);
block.occupied = block.value == 0;
