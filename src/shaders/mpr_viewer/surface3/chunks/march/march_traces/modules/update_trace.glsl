
// Compute trace distance
trace.distance += ray.spacing;

// Compute trace position
trace.position = camera.position + ray.direction * trace.distance;

// Compute intersection of trace based of difference
trace.intensity = texture(u_textures.binary_map, trace.position).r;

// Compute trace break conditions
trace.terminated = trace.distance > ray.end_distance;
trace.intersected = trace.intensity > 0.0;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
