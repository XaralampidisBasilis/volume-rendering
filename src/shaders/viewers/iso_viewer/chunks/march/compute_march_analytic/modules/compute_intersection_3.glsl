
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
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
voxel.value = voxel.texture_sample.r;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.texture_sample.gba);

// update error
trace.error = u_rendering.min_value - voxel.value;

// Compute temp
Trace temp_trace = trace;
Voxel temp_voxel = voxel;

for (int iter = 0; iter < int(u_debugging.variable3); iter++) 
{
    // newton–raphson method to update trace
    trace.error = u_rendering.min_value - voxel.value;
    trace.derivative = dot(voxel.gradient, ray.step_direction);
    trace.distance = trace.distance + u_debugging.variable1 * trace.error / trace.derivative;
    trace.position = camera.position + ray.step_direction * trace.distance; 

    // update voxel
    voxel.texture_coords = trace.position * u_volume.inv_size;
    voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
    voxel.value = voxel.texture_sample.r;
    #include "./compute_gradients"
}

// Rollback if no improvement
if (abs(trace.error) > abs(temp_trace.error)) 
{
    voxel = temp_voxel;
    trace = temp_trace;
}