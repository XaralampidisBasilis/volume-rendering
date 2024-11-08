
// compute block min and max positions in space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// reverse trace to the start of the block and a bit before
float backstep_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
backstep_distance += u_volume.spacing_length * 2.0;
trace.skipped_distance -= backstep_distance;

// take a backstep 
trace.distance -= backstep_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// sample the volume 
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - u_raymarch.sample_threshold;

// Compute the gradient
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;

// check conditions
trace.terminated = abs(ray.span_distance) < PICO_TOLERANCE || trace.distance > ray.end_distance;
trace.suspended = !trace.terminated && trace.step_count >= ray.max_step_count;
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
trace.update = !(trace.intersected || trace.terminated || trace.suspended);