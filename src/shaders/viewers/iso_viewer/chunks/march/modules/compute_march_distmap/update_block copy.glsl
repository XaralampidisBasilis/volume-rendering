// Compute block coords from ray end position
block.coords = ivec3(trace.position * u_distmap.inv_spacing);
block.texture_coords = trace.position * u_distmap.inv_size;

vec3 t = mod(trace.position * u_distmap.inv_spacing, 1.0);


// Sample the distance map and compute if block is occupied
block.value = texture(u_textures.distmap, block.texture_coords, 0).r * 255.0;
block.occupied = block.value < 0;

// Compute block min max coords in distance map
block.min_coords = block.coords - block.value + 1;
block.max_coords = block.coords + block.value + 0;

// Compute block min max position in model space  
block.min_position = vec3(block.min_coords) * u_distmap.spacing;
block.max_position = vec3(block.max_coords) * u_distmap.spacing;
