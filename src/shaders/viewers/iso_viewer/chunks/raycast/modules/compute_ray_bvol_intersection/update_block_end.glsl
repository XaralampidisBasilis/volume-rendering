
// Compute block coords from ray end position
block.coords = ivec3(ray.end_position * u_distmap.inv_spacing);
float block_max_value = 255.0 - MILLI_TOLERANCE;

// Sample the distance map and compute if block is occupied
block.value = int(block_max_value * texelFetch(u_textures.distmap, block.coords, 0).r);
block.occupied = block.value == 0;

// Compute block min max coords in distance map
block.min_coords = block.coords - block.value + 1;
block.max_coords = block.coords + block.value + 0;

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords) - MILLI_TOLERANCE) * u_distmap.spacing;
block.max_position = (vec3(block.max_coords) + MILLI_TOLERANCE) * u_distmap.spacing;
