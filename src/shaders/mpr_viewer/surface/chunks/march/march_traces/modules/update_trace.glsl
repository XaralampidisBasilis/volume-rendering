
// Compute distance
trace.distance += trace.spacing;

// Compute position
trace.position = camera.position + ray.direction * trace.distance;

// Sample distance map
ivec3 coords = ivec3(trace.position);
int cheby_distance = texelFetch(u_textures.distance_map, coords, 0).r;
trace.spacing = (cheby_distance == 1) ? ray.spacing : float(cheby_distance);

// Compute trace break conditions
trace.terminated = (trace.distance > ray.end_distance);
trace.intersected = (cheby_distance == 0);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
