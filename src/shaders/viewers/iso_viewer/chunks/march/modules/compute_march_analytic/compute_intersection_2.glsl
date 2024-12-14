
// compute solution
cell.coeffs = sample_matrix * cell.values;
vec3 solutions = cubic_solver(cell.coeffs, u_rendering.min_value);
vec3 is_inside = inside_closed(0.0, 1.0, solutions);
float solution = mmin(mmix(1.0, solutions, is_inside));
ivec2 indices = ivec2(floor(solution * 3.0), ceil(solution * 3.0));

// update previous trace
prev_trace.distance = cell.distances[indices.x];
prev_trace.distance = max(prev_trace.distance, ray.start_distance);
prev_trace.position = camera.position + ray.step_direction * prev_trace.distance; 

// update trace 
trace.distance = cell.distances[indices.y];
trace.distance = min(trace.distance, ray.end_distance);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update previous voxel
prev_voxel.coords = ivec3(prev_trace.position * u_volume.inv_spacing);
prev_voxel.texture_coords = prev_trace.position * u_volume.inv_size;
prev_voxel.value = cell.values[indices.x];

// update voxel
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.value = cell.values[indices.y];
trace.error = u_rendering.min_value - voxel.value;
