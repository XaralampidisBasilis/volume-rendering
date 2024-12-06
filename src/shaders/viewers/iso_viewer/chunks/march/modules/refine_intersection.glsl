
// Compute intervals
vec2 voxel_values = vec2(prev_voxel.value, voxel.value);
vec2 trace_distances = vec2(prev_trace.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.box_start_distance, ray.box_end_distance);

// Compute temporary objects
Trace temp_trace = trace;
Voxel temp_voxel = voxel;

// Compute iterative bisection
for (int iter = 0; iter < 10; iter++, trace.step_count++) 
{
    // update trace
    float lerp = map(voxel_values.x, voxel_values.y, u_rendering.min_value);
    trace.distance = mix(trace_distances.x, trace_distances.y, lerp);
    trace.position = camera.position + ray.step_direction * trace.distance;

    // update voxel
    voxel.texture_coords = trace.position * u_volume.inv_size;
    voxel.value = texture(u_textures.taylormap, voxel.texture_coords).r;

    // update interval
    float interval = step(u_rendering.min_value, voxel.value);
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
if (abs(voxel.value_error) > abs(temp_voxel.value_error)) 
{
    voxel = temp_voxel;
    trace = temp_trace;
}
else 
{
    // update voxel
    voxel.gradient = texture(u_textures.taylormap, voxel.texture_coords).gba;
    voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

    // update trace
    trace.normal = - normalize(voxel.gradient);
    trace.derivative = dot(voxel.gradient, ray.step_direction);
}
