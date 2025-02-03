
// Compute block coords from trace position
block.coords = ivec3((trace.position + u_intensity_map.spacing * 0.5) * u_distance_map.inv_spacing);

// Sample the distance map and compute if block is occupied
block.cheby_distance = int(round(texelFetch(u_textures.distance_map, block.coords, 0).r * 255.0));
block.occupied = block.cheby_distance == 0;

// Compute block min max coords in distance map
block.min_coords = block.coords - max(0, block.cheby_distance - 1);
block.max_coords = block.coords + max(0, block.cheby_distance - 1);

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords + 0) - MILLI_TOLERANCE) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;
block.max_position = (vec3(block.max_coords + 1) + MILLI_TOLERANCE) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;  

// Compute entry and exit distances
block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif