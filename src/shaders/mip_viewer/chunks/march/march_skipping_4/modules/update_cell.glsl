
// compute cell coordinates from previous cell exit position
cell.coords = ivec3(cell.exit_position * u_intensity_map.inv_spacing + 0.5);

// compute cell bounding box in model coordinates
cell.min_position = (vec3(cell.coords) - 0.5 - MILLI_TOLERANCE) * u_intensity_map.spacing;
cell.max_position = (vec3(cell.coords) + 0.5 + MILLI_TOLERANCE) * u_intensity_map.spacing;

// compute cell ray intersection to find entry and exit distances, 
cell.entry_distance = cell.exit_distance;
cell.entry_position = cell.exit_position;
cell.exit_distance = intersect_box_max(cell.min_position, cell.max_position, camera.position, ray.direction);
cell.exit_position = camera.position + ray.direction * cell.exit_distance; 

// update trace
trace.distance = mix(cell.entry_distance, cell.exit_distance, 0.5);
trace.position = mix(cell.entry_position, cell.exit_position, 0.5);
trace.uvw = trace.position * u_intensity_map.inv_size;
trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

// update maximum intensity projection trace 
mip.intensity = max(mip.intensity, trace.intensity);

// termination condition
cell.terminated = cell.exit_distance > block.exit_distance; // REALLY IMPORTANT FOR OPTIMIZATION

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
stats.num_steps += 1;
#endif
