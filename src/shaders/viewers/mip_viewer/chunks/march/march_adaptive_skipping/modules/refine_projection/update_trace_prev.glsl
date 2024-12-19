
trace_prev = max_trace;

// compute distance
trace_prev.distance -= 0.5 * ray.max_step_distance / exp2(float(iter));
trace_prev.distance = clamp(trace_prev.distance, ray.box_start_distance, ray.box_end_distance);

// compute position
trace_prev.position = ray.camera_position + ray.step_direction * trace_prev.distance;
trace_prev.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace_prev.voxel_texture_coords = trace_prev.position * u_volume.inv_size;

// compute sample
trace_prev.sample_data = texture(u_textures.volume, trace_prev.voxel_texture_coords);
trace_prev.sample_value = trace_prev.sample_data.r;

// compute gradient
trace_prev.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace_prev.gradient_magnitude = length(trace_prev.gradient);
trace_prev.gradient_direction = normalize(trace_prev.gradient);
trace_prev.derivative = dot(trace_prev.gradient, ray.step_direction);
