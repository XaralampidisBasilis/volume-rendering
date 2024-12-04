
// Compute trace distance and position with ray block intersection 
// prev_trace.distance = trace.distance;

// intersect ray with block to find start distance and position
trace.distance = intersect_box_max(block.min_position, block.max_position, ray.camera_position, ray.step_direction);

// update ray start position
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;

// Set step distance
trace.step_distance = ray.step_distance;

// update conditions
trace.suspended = trace.step_count >= u_rendering.max_step_count;
trace.terminated = trace.distance > ray.end_distance;
trace.intersected = trace.value_error > 0.0;
trace.update = !trace.intersected && !trace.terminated && !trace.suspended;

// update cumulative stats
// trace.skipped_distance += trace.distance - prev_trace.distance;

// update skip count
