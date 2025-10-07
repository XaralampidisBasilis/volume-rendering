
// Store previous distance
trace.prev_distance = trace.distance;

// Increment distance
trace.distance += trace.spacing;

// Compute position
trace.position = camera.position + ray.direction * trace.distance; 

// Compute termination condition
trace.terminated = trace.distance > ray.end_distance; 

// update stats
#if STATS_ENABLED == 1
stats.num_traces += 1;
#endif