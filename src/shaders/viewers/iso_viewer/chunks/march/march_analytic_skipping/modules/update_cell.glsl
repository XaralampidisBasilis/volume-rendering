
// compute cell coords from trace position
cell.coords = ivec3(trace.position * u_volume.inv_spacing + 0.5);
cell.min_position = (vec3(cell.coords) - 0.5 - MILLI_TOLERANCE) * u_volume.spacing;
cell.max_position = (vec3(cell.coords) + 0.5 + MILLI_TOLERANCE) * u_volume.spacing;

// // compute distances
cell.bounds = intersect_box(cell.min_position, cell.max_position, camera.position, ray.step_direction);
cell.distances = mmix(cell.bounds.x, cell.bounds.y, sample_distances);

// compute values
cell.values.x = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.x).r;
cell.values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.y).r;
cell.values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.z).r;
cell.values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.w).r;

// compute coeffs
cell.coeffs = sample_matrix * cell.values;

// check intersection
trace.intersected = is_cubic_solvable(cell.coeffs, u_rendering.threshold_value, 0.0, 1.0, cell.values.x, cell.values.w);


