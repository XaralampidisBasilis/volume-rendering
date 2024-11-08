trace_prev = trace;

// take a backstep in order to compute the previouse trace 
trace_prev.distance -= trace.step_distance;
trace_prev.position = ray.origin_position + ray.step_direction * trace_prev.distance;
trace_prev.voxel_texture_coords = trace_prev.position * u_volume.inv_size;

// sample the volume at previous step and save the trace
trace_prev.sample_data = texture(u_textures.volume, trace_prev.voxel_texture_coords);
trace_prev.sample_value = trace_prev.sample_data.r;
trace_prev.sample_error = trace_prev.sample_value - u_raymarch.sample_threshold;

// Compute the gradient and its norm in a single step
trace_prev.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace_prev.sample_data.gba);
trace_prev.derivative = dot(trace_prev.gradient, ray.step_direction);
trace_prev.normal = -normalize(trace_prev.gradient);
