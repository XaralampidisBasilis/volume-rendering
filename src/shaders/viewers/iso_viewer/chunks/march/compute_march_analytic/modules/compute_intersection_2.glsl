
// compute solution
cell.coeffs = sample_matrix * cell.values;
vec3 solutions = cubic_solver(cell.coeffs, u_rendering.min_value);
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
voxel.error = voxel.value - u_rendering.min_value;
trace.error = voxel.error;


// Set next 
Trace next_trace = trace;
Voxel next_voxel = voxel;

// update next trace 
next_trace.distance = mix(cell.bounds.x, cell.bounds.y, solution);
next_trace.distance += ray.step_distance * u_debugging.variable1;
next_trace.distance = min(next_trace.distance, ray.end_distance);

// update next voxel
next_voxel.texture_coords = trace.position * u_volume.inv_size;
next_voxel.texture_sample = texture(u_textures.taylor_map, next_voxel.texture_coords);
next_voxel.value = next_voxel.texture_sample.r;
next_voxel.error = next_voxel.value - u_rendering.min_value;


// update previous trace 
prev_trace.distance = mix(cell.bounds.x, cell.bounds.y, solution);
prev_trace.distance -= ray.step_distance * u_debugging.variable1;
prev_trace.distance = max(prev_trace.distance, ray.start_distance);

// update previous voxel
prev_voxel.texture_coords = prev_trace.position * u_volume.inv_size;
prev_voxel.texture_sample = texture(u_textures.taylor_map, prev_voxel.texture_coords);
prev_voxel.value = prev_voxel.texture_sample.r;
prev_voxel.error = prev_voxel.value - u_rendering.min_value;


debug.variable1 = vec4(vec3(voxel.error * prev_voxel.error > 0.0), 1.0);

// Compute iterative bisection method
vec2 errors = vec2(prev_voxel.error, next_voxel.error);
vec2 distances = vec2(prev_trace.distance, next_trace.distance);

for (int iter = 0; iter < 10; iter++) 
{
    // update trace
    next_trace.distance = mix(distances.x, distances.y, 0.5);
    next_trace.position = camera.position + ray.step_direction * next_trace.distance;

    // update voxel
    next_voxel.texture_coords = next_trace.position * u_volume.inv_size;
    next_voxel.value = texture(u_textures.taylor_map, next_voxel.texture_coords).r;
    next_voxel.error = next_voxel.value - u_rendering.min_value;

    // update interval
    float interval = step(0.0, errors.x * next_voxel.error);

    errors = mix(
        vec2(errors.x, next_voxel.error), 
        vec2(next_voxel.error, errors.y), 
        interval);

    distances = mix(
        vec2(distances.x, next_trace.distance), 
        vec2(next_trace.distance, distances.y), 
        interval);
}

// Rollback if no improvement
if (abs(voxel.error) > abs(next_voxel.error)) 
{
    voxel = next_voxel;
    trace = next_trace;
    trace.error = voxel.error;
}