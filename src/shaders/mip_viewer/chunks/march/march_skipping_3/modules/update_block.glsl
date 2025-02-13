
// Compute block coords from trace position
block.coords += block.coords_step;

// Compute block bounding box position in model space  
block.min_position = vec3(block.coords + 0) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;  

// Compute block entry/exit distances
block.entry_distance = block.exit_distance;
block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction, block.coords_step);

// Compute block entry/exit positions
block.entry_position = block.exit_position;
block.exit_position = camera.position + ray.direction * block.exit_distance;

// Sample the distance map and compute if block is occupied
block.max_intensity = texelFetch(u_textures.maxima_map, block.coords, 0).r;

// Compute termination condition
block.occupied = mip.intensity < block.max_intensity;
block.terminated = block.exit_distance > ray.end_distance;

// Update trace 
trace.distance = block.entry_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif