
// compute distances
cell.bounds = intersect_box(cell.min_position, cell.max_position, camera.position, ray.step_direction);
cell.bounds = clamp(cell.bounds, box.entry_distance, box.exit_distance);
cell.distances = mmix(cell.bounds.x, cell.bounds.y, sample_distances);

// compute coeffs
cell.values.x = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.x).r;
cell.values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.y).r;
cell.values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.z).r;
cell.values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.w).r;
cell.coeffs = sample_matrix * cell.values;

// compute solution
cell.coeffs = sample_matrix * cell.values;
vec3 solutions = cubic_solver(cell.coeffs, u_rendering.threshold_value);
vec3 is_inside = inside_closed(0.0, 1.0, solutions);
float solution = mmin(mmix(1.0, solutions, is_inside));

// update trace 
trace.distance = mix(cell.bounds.x, cell.bounds.y, solution);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update voxel
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
voxel.value = voxel.texture_sample.r;
voxel.error = voxel.value - u_rendering.threshold_value;
