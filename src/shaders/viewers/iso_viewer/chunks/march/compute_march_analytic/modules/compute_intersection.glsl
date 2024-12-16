
// compute solution
cell.coeffs = sample_matrix * cell.values;
vec3 solutions = cubic_solver(cell.coeffs, u_rendering.min_value);
vec3 is_inside = inside_open(0.0, 1.0, solutions);
float solution = mmin(mmix(1.0, solutions, is_inside));

// update trace 
prev_trace = trace;
trace.distance = mix(cell.bounds.x, cell.bounds.y, solution);
trace.distance = clamp(trace.distance, ray.start_distance, ray.end_distance);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update voxel
prev_voxel = voxel;
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
voxel.value = voxel.texture_sample.r;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.texture_sample.gba);

// update error
trace.error = u_rendering.min_value - voxel.value;
