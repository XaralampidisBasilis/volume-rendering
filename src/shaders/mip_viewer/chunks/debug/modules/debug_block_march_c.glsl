
block.exit_distance = ray.start_distance;
block.exit_position = ray.start_position;

for (int i = 0; i < u_debugging.block_count; i++)
{
    // Compute block coords from trace position
    block.coords = ivec3((block.exit_position + u_intensity_map.spacing * 0.5) * u_distance_map.inv_spacing);

    // Compute maxima chebysev distance
    block.cheby_distance = sample_anisotropic_distance_map(block.coords, ray.octant);

    // Compute block bounding box coords
    block.min_coords = block.coords - block.cheby_distance;
    block.max_coords = block.coords + block.cheby_distance;

    // Compute block bounding box position in model space  
    block.min_position = (vec3(block.min_coords + 0) - MILLI_TOLERANCE) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;
    block.max_position = (vec3(block.max_coords + 1) + MILLI_TOLERANCE) * u_distance_map.spacing - u_intensity_map.spacing * 0.5;  

    // Compute block entry/exit distances
    block.entry_distance = block.exit_distance;
    block.exit_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.direction);

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