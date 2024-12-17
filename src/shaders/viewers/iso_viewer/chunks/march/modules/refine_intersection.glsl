
// Compute intervals
vec2 voxel_values = vec2(prev_voxel.value, voxel.value);
vec2 trace_distances = vec2(prev_trace.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.start_distance, ray.end_distance);

// Compute temporary objects
Trace temp_trace = trace;
Voxel temp_voxel = voxel;

// Compute iterative bisection
for (int iter = 0; iter < 10; iter++, trace.step_count++) 
{
    // update trace
    float lerp = map(voxel_values.x, voxel_values.y, u_rendering.threshold_value);
    trace.distance = mix(trace_distances.x, trace_distances.y, lerp);
    trace.position = camera.position + ray.step_direction * trace.distance;

    // update voxel
    voxel.texture_coords = trace.position * u_volume.inv_size;
    voxel.gradient = texture(u_textures.taylor_map, voxel.texture_coords).gba;
    voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);
    voxel.value = texture(u_textures.taylor_map, voxel.texture_coords).r;
    voxel.error = voxel.value - u_rendering.threshold_value;

    // update interval
    float interval = step(u_rendering.threshold_value, voxel.value);
    voxel_values = mix(
        vec2(voxel.value, voxel_values.y), 
        vec2(voxel_values.x, voxel.value), 
        interval);

    trace_distances = mix(
        vec2(trace.distance, trace_distances.y), 
        vec2(trace_distances.x, trace.distance), 
        interval);
}

// Rollback if no improvement
if (abs(voxel.value) > abs(temp_voxel.value)) 
{
    voxel = temp_voxel;
    trace = temp_trace;
}
else 
{
    // update trace
    trace.derivative = dot(voxel.gradient, ray.step_direction);
}
