
// Compute trace distance
trace.distance += trace.spacing;

// Compute trace position
trace.position = camera.position + ray.direction * trace.distance;
trace.coords = ivec3(trace.position * u_intensity_map.inv_spacing);
trace.uvw = trace.position * u_intensity_map.inv_size;

// Compute intersection of trace 
trace.intersected = texture(u_textures.binary_map, trace.uvw).r > 0;

// Compute trace termination condition
trace.terminated = trace.distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
