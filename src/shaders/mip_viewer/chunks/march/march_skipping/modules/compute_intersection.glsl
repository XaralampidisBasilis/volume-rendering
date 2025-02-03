
// compute distances
vec2 cell_distances = intersect_box(cell.min_position, cell.max_position, camera.position, ray.direction);
cell_distances = clamp(cell_distances, box.entry_distance, box.exit_distance);
cell.entry_distance = cell_distances.x;
cell.exit_distance = cell_distances.y;
cell.sample_distances = mmix(cell.entry_distance, cell.exit_distance, weights_vec4);

// compute intensities
cell.sample_intensities.x = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.x).r;
cell.sample_intensities.y = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.y).r;
cell.sample_intensities.z = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.z).r;
cell.sample_intensities.w = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.w).r;

// compute coefficients
cell.intensity_coeffs = inv_vander_mat4 * cell.sample_intensities;

// compute solution
vec3 solutions = cubic_solver(cell.intensity_coeffs, u_rendering.intensity);
vec3 is_inside = inside_closed(0.0, 1.0, solutions);
float min_solution = mmin(mmix(1.0, solutions, is_inside));

// update trace 
trace.distance = mix(cell.entry_distance, cell.exit_distance, min_solution);
trace.position = camera.position + ray.direction * trace.distance; 
trace.uvw = trace.position * u_intensity_map.inv_size; 
trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;
trace.error = trace.intensity - u_rendering.intensity;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 4;
#endif
