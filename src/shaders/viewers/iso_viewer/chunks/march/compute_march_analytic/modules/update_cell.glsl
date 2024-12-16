
// compute cell coords from trace position
cell.coords += cell.coords_step;
cell.min_position = (vec3(cell.coords) + 0.5) * u_volume.spacing;
cell.max_position = (vec3(cell.coords) + 1.5) * u_volume.spacing;

// update position
cell.bounds.x = cell.bounds.y;
cell.bounds.y = intersect_box_max(cell.min_position, cell.max_position, camera.position, ray.step_direction, cell.coords_step);

// update distances
cell.distances.x = cell.distances.w;
cell.distances.yzw = mmix(cell.bounds.x, cell.bounds.y, sample_distances.yzw);

// update values
cell.values.x = cell.values.w;
cell.values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.y).r;
cell.values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.z).r;
cell.values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.w).r;

// update coeffs
cell.coeffs = sample_matrix * cell.values;

// update intersection
trace.intersected = is_cubic_solvable(cell.coeffs, u_rendering.min_value, 0.0, 1.0);


