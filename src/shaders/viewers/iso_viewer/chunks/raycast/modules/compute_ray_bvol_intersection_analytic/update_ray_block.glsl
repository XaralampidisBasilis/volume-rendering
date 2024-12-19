
// Compute block coords
block.coords += block.step_coords;

// Sample the distance map and compute if block is occupied
block.value = int(round(texelFetch(u_textures.distance_map, block.coords, 0).r * 255.0));
block.occupied = block.value == 0;

// Compute block min max coords in distance map
block.min_coords = block.coords - (block.value - 1);
block.max_coords = block.coords + (block.value - 1);

// Compute block min max position in model space  
block.min_position = vec3(block.min_coords + 0) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.max_coords + 1) * u_distmap.spacing - u_volume.spacing * 0.5;  