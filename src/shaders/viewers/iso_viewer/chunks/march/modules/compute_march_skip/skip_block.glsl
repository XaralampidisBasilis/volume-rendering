
// update count
block.skip_count++;

// update previous
prev_trace = trace;

// update position
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update conditions
trace.terminated = trace.distance > ray.end_distance;

// update cumulatives
trace.skipped_distance += trace.distance - prev_trace.distance;
