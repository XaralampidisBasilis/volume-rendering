
// Compute distance
trace.distance += trace.spacing;

// Compute position
// trace.position = ray.start_position + ray.direction * trace.distance;
trace.position += ray.direction * trace.spacing;
trace.uvw = u_volume.inv_dimensions * trace.position;

// Sample distance map
int spacing = texture(u_textures.distance_map, trace.uvw).r;
trace.spacing = max(float(spacing - 1), min_spacing);

// Compute trace break conditions
trace.terminated = (trace.distance > ray.span_distance);
trace.intersected = (spacing == 0);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
