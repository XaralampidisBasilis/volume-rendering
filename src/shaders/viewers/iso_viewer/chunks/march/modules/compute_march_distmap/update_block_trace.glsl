
// Compute trace distance and position with ray block intersection 
prev_trace.distance = trace.distance;

// intersect ray with block to find start distance and position
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);

// update ray start position
trace.position = camera.position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.update = !trace.terminated;

// Set step distance
trace.step_distance = 0.0;

// update cumulative stats
trace.skipped_distance += trace.distance - prev_trace.distance;
