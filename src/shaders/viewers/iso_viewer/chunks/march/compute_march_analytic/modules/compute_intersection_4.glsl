
// compute solution
float solutions[7];
cell.coeffs = sample_matrix * cell.values;
cubic_solver_least_squares(solutions, cell.coeffs, u_rendering.min_value, 0.0, 1.0);

float solution = 1.0;
for (int i = 0; i < 7; i++)
{
    solution = min(solution, solutions[i]);
}

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
