
// Compute block coords from ray end position
block.coords = ivec3(ray.end_position * u_distmap.inv_spacing);

// Sample the distance map and compute if block is occupied
block.value = int(texelFetch(u_textures.distmap, block.coords, 0).r * 255.0);
block.occupied = block.value <= 1;

// Compute block min max coords in distance map
block.min_coords = block.coords - block.value + 1;
block.max_coords = block.coords + block.value + 0;

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords) - CENTI_TOLERANCE) * u_distmap.spacing;
block.max_position = (vec3(block.max_coords) + CENTI_TOLERANCE) * u_distmap.spacing;
