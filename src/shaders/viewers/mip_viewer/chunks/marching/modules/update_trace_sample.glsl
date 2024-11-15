
// sample volume at start position
trace_prev.sample_value = trace.sample_value;
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;

if (u_raymarch.min_sample_value < trace.sample_value && trace.sample_value < u_raymarch.max_sample_value)
{
    trace.max_sample_value = max(trace.max_sample_value, trace.sample_value);
}

// sample gradient
// #include "./compute_trace_gradient"
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
