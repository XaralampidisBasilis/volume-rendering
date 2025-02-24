
// compute cell coordinates from previous cell exit position
cell.coords = ivec3(cell.exit_position * u_intensity_map.inv_spacing + 0.5);

// compute cell bounding box in model coordinates
cell.min_position = (vec3(cell.coords) - 0.5 - MILLI_TOLERANCE) * u_intensity_map.spacing;
cell.max_position = (vec3(cell.coords) + 0.5 + MILLI_TOLERANCE) * u_intensity_map.spacing;

// compute cell ray intersection to find entry and exit distances, 
cell.entry_distance = cell.exit_distance;
cell.exit_distance = intersect_box_max(cell.min_position, cell.max_position, camera.position, ray.direction);

cell.entry_position = cell.exit_position;
cell.exit_position = camera.position + ray.direction * cell.exit_distance; 

// given the entry and exit compute the sampling distances inside the cell
cell.sample_distances.x = cell.sample_distances.w;
cell.sample_distances.yzw = mmix(cell.entry_distance, cell.exit_distance, weights_vec4.yzw);

// compute the intensity samples inside the cell from the intensity map texture
cell.sample_intensities.x = cell.sample_intensities.w;
cell.sample_intensities.y = texture(u_textures.intensity_map, camera.uvw + ray.direction_uvw * cell.sample_distances.y).r;
cell.sample_intensities.z = texture(u_textures.intensity_map, camera.uvw + ray.direction_uvw * cell.sample_distances.z).r;
cell.sample_intensities.w = texture(u_textures.intensity_map, camera.uvw + ray.direction_uvw * cell.sample_distances.w).r;

// from the sampled intensities we can compute the trilinear interpolation cubic polynomial coefficients
cell.intensity_coeffs = inv_vander_mat4 * cell.sample_intensities;

// given the polynomial we can compute if we intersect the isosurface inside the cell
cubic_maxima(trace.intensity, cell.intensity_coeffs, weights_vec4.xw, cell.sample_intensities.xw);

// update maximum intensity projection trace 
mip.intensity = max(mip.intensity, trace.intensity);

// termination condition
cell.terminated = cell.exit_distance > block.exit_distance; // REALLY IMPORTANT FOR OPTIMIZATION

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 3;
stats.num_steps += 1;
#endif
