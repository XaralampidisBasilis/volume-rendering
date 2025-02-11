
// Compute block coords from previous coords step
block.coords += block.coords_step;

// Compute block max intensity and check occupation
block.max_intensity = texelFetch(u_textures.maxima_map, block.coords, 0).r;
block.occupied = mip.intensity < block.max_intensity;

// Compute block bounding box in model space  
block.min_position = vec3(block.coords + 0) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_maxima_map.spacing - u_intensity_map.spacing * 0.5;  

// Compute ray exit distance from block and next coords step
block.entry_distance = block.exit_distance;
block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction, block.coords_step);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
stats.num_skips += 1;
#endif