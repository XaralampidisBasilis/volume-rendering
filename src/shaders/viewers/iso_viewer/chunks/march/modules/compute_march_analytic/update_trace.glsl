
// update previous
prev_trace = trace;

// update position
trace.distance = trace_bounds.y;
trace.position = camera.position + ray.step_direction * trace.distance; 

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;

