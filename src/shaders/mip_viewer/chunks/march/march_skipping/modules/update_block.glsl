
// Compute block coords from trace position
block.coords += block.coords_step;

// Sample the distance map and compute if block is occupied
block.max_intensity = texelFetch(u_textures.maxima_map, block.coords, 0).r;
block.occupied = mip.intensity < block.max_intensity;

// Compute block min max position in model space  
block.min_position = (vec3(block.coords + 0) - MILLI_TOLERANCE) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;
block.max_position = (vec3(block.coords + 1) + MILLI_TOLERANCE) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;  

// Compute entry and exit distances
block.exit_distance = intersect_box_max
(
    block.min_position, 
    block.max_position, 
    camera.position, 
    ray.direction, 
    block.coords_step
);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif