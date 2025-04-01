
// Update position
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;

// Sample distance map
trace.uvw = u_volume.inv_dimensions * trace.position;
int spacing = texture(u_textures.distance_map, trace.uvw).r;
trace.spacing = max(float(spacing - 1), min_spacing);

// Compute break conditions
trace.terminated = (trace.distance > ray.span_distance);
trace.intersected = (spacing == 0);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
