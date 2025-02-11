
// Set block from ray start
block.exit_distance = ray.start_distance;
block.exit_position = ray.start_position;
mip.intensity = 0.0;

for (int i = 0; i < MAX_BLOCK_COUNT; i++) 
{
    // Compute block coords from previous block exit position
    block.coords = ivec3((block.exit_position + u_intensity_map.spacing * 0.5) * u_minima_distance_map.inv_spacing);

    // Compute chebysev distance to next block
    vec2 block_data = texelFetch(u_textures.minima_distance_map, block.coords, 0).rg;
    block.cheby_distance = int(round(block_data.g * 255.0));
    block.min_intensity = block_data.r;

    // Compute block bounding box coords
    block.min_coords = block.coords - block.cheby_distance;
    block.max_coords = block.coords + block.cheby_distance;

    // Compute block bounding box position in model space  
    block.min_position = (vec3(block.min_coords + 0) - MILLI_TOLERANCE) * u_minima_distance_map.spacing - u_intensity_map.spacing * 0.5;
    block.max_position = (vec3(block.max_coords + 1) + MILLI_TOLERANCE) * u_minima_distance_map.spacing - u_intensity_map.spacing * 0.5;  

    // Compute ray-block intersection and entry/exit distances
    block.entry_distance = block.exit_distance;
    block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction);

    // Compute block entry/exit positions
    block.entry_position = block.exit_position;
    block.exit_position = camera.position + ray.direction * block.exit_distance;

    // Compute termination condition
    block.terminated = block.exit_distance > ray.end_distance;

    // Update maximum intensity projection with block min intensity as lower bound
    mip.intensity = max(mip.intensity, block.min_intensity);

    // Update stats
    #if STATS_ENABLED == 1
    stats.num_fetches += 1;
    #endif

    if (block.terminated) 
    {
        break;
    }  
}