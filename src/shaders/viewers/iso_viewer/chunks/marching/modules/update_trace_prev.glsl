trace_prev = trace;

// take a backstep in order to compute the previouse trace 
trace_prev.distance -= trace.step_distance;
trace_prev.position = ray.origin_position + ray.step_direction * trace_prev.distance;
trace_prev.voxel_coords = ivec3(floor(trace_prev.position * volume.inv_spacing));
trace_prev.voxel_texture_coords = trace_prev.position * volume.inv_size;

// sample the volume at previous step and save the trace
trace_prev.sample_data = texture(textures.volume, trace_prev.voxel_texture_coords);
trace_prev.sample_value = trace_prev.sample_data.r;
trace_prev.sample_error = trace_prev.sample_value - raymarch.sample_threshold;

// Compute the gradient and its norm in a single step
trace_prev.gradient = mix(volume.min_gradient, volume.max_gradient, trace_prev.sample_data.gba);
trace_prev.gradient_magnitude = length(trace_prev.gradient);
trace_prev.gradient_direction = normalize(trace_prev.gradient);
trace_prev.derivative_1st = dot(trace_prev.gradient, ray.step_direction);
trace_prev.normal = -trace_prev.gradient_direction;
