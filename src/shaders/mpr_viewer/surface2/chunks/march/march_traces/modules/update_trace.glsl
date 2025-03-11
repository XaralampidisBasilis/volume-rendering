
// Copy previous trace
prev_trace = trace;

// Compute trace distance
trace.distance += trace.spacing;

// Compute trace position
trace.position = camera.position + ray.direction * trace.distance;

// Compute intersection of trace based of difference
trace.intensity = texture(u_textures.binary_map, trace.position).r;
trace.intersected = abs(trace.intensity - prev_trace.intensity) > 0.0;

// Compute trace termination condition
trace.terminated = trace.distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
