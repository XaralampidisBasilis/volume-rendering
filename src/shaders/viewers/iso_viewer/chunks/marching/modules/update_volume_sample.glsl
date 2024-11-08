
// Extract intensity and gradient from volume data in a single texture lookup
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - u_raymarch.sample_threshold;

// Compute the gradient and its norm in a single step
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -normalize(trace.gradient);
