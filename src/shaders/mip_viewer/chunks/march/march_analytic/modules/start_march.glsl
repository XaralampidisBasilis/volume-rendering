
// start trace at ray start distance
trace.distance = ray.start_distance;
trace.position = camera.position + ray.direction * trace.distance;
mip = trace;

// start cell at trace position
cell.coords = ivec3(trace.position * u_intensity_map.inv_spacing + 0.5);
cell.coords_step = ivec3(0);
cell.exit_distance = trace.distance;
cell.sample_distances.w = trace.distance;
cell.sample_intensities.w = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.w).r;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif