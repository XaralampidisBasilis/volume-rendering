
// terminate trace position
trace.distance = ray.box_end_distance;
trace.position = ray.box_end_position;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// terminate trace sample
trace.sample_data = vec4(0.0);
trace.sample_value = 0.0;
trace.sample_error = -u_raymarch.sample_threshold;

// terminate trace gradient
trace.gradient = vec3(0.0);
trace.gradient_magnitude = 0.0;
trace.gradient_direction = vec3(0.0);
trace.derivative_1st = 0.0;
trace.normal = -vec3(0.0);

// compute cummulative distances
trace.spanned_distance = ray.box_span_distance;
