
trace_next = max_trace;

// compute distance
trace_next.distance += 0.5 * ray.max_step_distance/ exp2(float(iter));
trace_next.distance = clamp(trace_next.distance, ray.box_start_distance, ray.box_end_distance);

// compute position
trace_next.position = ray.camera_position + ray.step_direction * trace_next.distance;
trace_next.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace_next.voxel_texture_coords = trace_next.position * u_volume.inv_size;

// compute sample
trace_next.sample_data = texture(u_textures.volume, trace_next.voxel_texture_coords);
trace_next.sample_value = trace_next.sample_data.r;

// compute gradient
trace_next.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace_next.gradient_magnitude = length(trace_next.gradient);
trace_next.gradient_direction = normalize(trace_next.gradient);
trace_next.derivative = dot(trace_next.gradient, ray.step_direction);
