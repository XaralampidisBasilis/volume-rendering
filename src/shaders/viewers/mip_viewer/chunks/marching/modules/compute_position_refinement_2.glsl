
// save the initial trace state for potential rollback
Trace prev_trace = trace;
Trace next_trace = trace;

vec2 derivatives;
vec2 distances;

if (max_trace.derivative > 0)

// #pragma unroll_loop_start
for (int i = 0; i < 10; i++) 
{
    // compute sample linear interpolation factor
    float mix_factor = map(prev_trace.derivative, next_trace.derivative, 0.0);

    // linearly interpolate positions based on sample 
    trace.distance = mix(prev_trace.distance, next_trace.distance, mix_factor);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // update sample
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;

    // update gradient
    trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
    trace.gradient_magnitude = length(trace.gradient);
    trace.gradient_direction = normalize(trace.gradient);
    trace.derivative = dot(trace.gradient, ray.step_direction);

     // select interval based on sample error 
    float select_interval = step(0.0, trace.derivative);
    values = mix(vec2(trace.sample_value, values.y), vec2(values.x, trace.sample_value), select_interval);
    distances = mix(vec2(trace.distance, distances.y), vec2(distances.x, trace.distance), select_interval);

    trace.step_count++;
}