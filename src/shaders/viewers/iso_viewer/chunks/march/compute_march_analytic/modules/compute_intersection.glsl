
// compute solution
cell.coeffs = sample_matrix * cell.values;
vec3 solutions = cubic_solver(cell.coeffs, u_rendering.threshold_value);
vec3 is_inside = inside_closed(0.0, 1.0, solutions);
float solution = mmin(mmix(1.0, solutions, is_inside));

// update trace 
trace.distance = mix(cell.bounds.x, cell.bounds.y, solution);
trace.distance = min(trace.distance, ray.end_distance);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update voxel
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
voxel.value = voxel.texture_sample.r;
voxel.error = voxel.value - u_rendering.threshold_value;

