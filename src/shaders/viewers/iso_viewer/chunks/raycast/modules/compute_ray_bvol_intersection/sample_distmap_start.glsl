
// Compute block coords from ray start position
block.coords = ivec3(ray.start_position * u_distmap.inv_spacing);

// Sample the distance map and compute if block is occupied
block.chebyshev_distance = int(255 * texelFetch(u_textures.distmap, block.coords, 0).r);
block.occupied = block.chebyshev_distance == 0;

// Compute the block dimension and size
block.dimensions = block.chebyshev_distance * u_distmap.division;
block.size = float(block.chebyshev_distance) * u_distmap.spacing;
