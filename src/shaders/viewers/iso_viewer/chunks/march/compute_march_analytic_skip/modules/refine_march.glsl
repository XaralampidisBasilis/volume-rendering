
// Compute block coords from trace position
block.coords = ivec3((trace.position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);

// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_distmap.spacing - u_volume.spacing * 0.5;  

// Refine trace position from block entry distance
trace.distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.distance -= u_volume.spacing_length * 0.5; // safeguard for numerical instabilities

// compute position
trace.distance = max(trace.distance, ray.start_distance);
trace.position = camera.position + ray.step_direction * trace.distance; 

// Continue trace march from refined position
for (int count = 0; count < MAX_TRACE_STEP_COUNT; count++, trace.step_count++) 
{
    #include "./update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./update_march"
    
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   