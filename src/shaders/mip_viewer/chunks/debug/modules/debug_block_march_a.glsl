
// Compute starting exit 
block.exit_distance = ray.start_distance;
block.exit_position = ray.start_position;

// Compute starting coords
block.coords_step = ivec3(0);
block.coords = ivec3((ray.start_position + u_intensity_map.spacing * 0.5) * u_distance_map.inv_spacing);

for (int i = 0; i < u_debugging.block_count; i++)
{
    // Compute block coords 
    block.coords += block.coords_step;

    // Compute chebysev distance
    block.cheby_distance = sample_distance_map(block.coords);

    // Compute block bounding box position in model space  
    block.min_position = vec3(block.coords + 0) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;
    block.max_position = vec3(block.coords + 1) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;  

    // Compute block entry/exit distances
    block.entry_distance = block.exit_distance;
    block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction, block.coords_step);

    // Compute block entry/exit positions
    block.entry_position = block.exit_position;
    block.exit_position = camera.position + ray.direction * block.exit_distance;

    // Compute termination condition
    block.terminated = block.exit_distance > ray.end_distance;

    if (block.terminated)
    {
        break;
    }
}