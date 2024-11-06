
/* Update block */

    // compute block min and max positions in model space based on coordinates
    // add a small tolerance in order to skip into the next block
    vec3 block_min_position = vec3(trace.block_coords + 0) - MILLI_TOL;
    vec3 block_max_position = vec3(trace.block_coords + 1) + MILLI_TOL;
    block_min_position *= occumap.spacing;
    block_max_position *= occumap.spacing;

    // intersect ray with block to find the skipping distance
    trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, ray.step_direction);
    trace.skipped_distance += trace.skip_distance;
    trace.skip_count += 1;

    // update trace position
    trace_prev = trace;
    trace.distance += trace.skip_distance;
    trace.position = ray.origin_position + ray.step_direction * trace.distance; 
    trace.spanned_distance = trace.distance - ray.box_start_distance;

    // compute trace volume texture coordinates
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;
