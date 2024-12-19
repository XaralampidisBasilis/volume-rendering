
// Compute block coords from trace position
block.coords = ivec3(trace.position * u_distmap.inv_spacing);
block.min_position = vec3(block.coords + 0) * u_distmap.spacing;
block.max_position = vec3(block.coords + 1) * u_distmap.spacing;

// Refine trace position from block entry distance
trace.distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.distance -= u_volume.spacing_length * 2.0;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = camera.position + ray.step_direction * trace.distance; 

// Continue trace march from refined position
for (trace.step_count; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./update_voxel" 

    if (trace.intersected)
    {
        break;
    }

    #include "./update_trace" 

    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}