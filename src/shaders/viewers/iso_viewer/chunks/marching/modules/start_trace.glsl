// set cummulative distances
trace.stepped_distance = 0.0;
trace.spanned_distance = 0.0;
trace.skipped_distance = 0.0;

// set counds
trace.step_count = 0;
trace.skip_count = 0;

// take a backstep in order to compute the previouse trace 
trace.distance = ray.start_distance;
trace.position = ray.start_position;
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

// compute step stretching factor based on distance
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_streching"
#endif

// compute step sclaling factor based on gradients
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update trace step distance
trace.step_distance = ray.step_distance * trace.step_scaling;

// set states
trace.terminated = abs(ray.span_distance) < PICO_TOLERANCE || trace.distance > ray.end_distance;
trace.suspended = !trace.terminated && trace.step_count >= ray.max_step_count;
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
trace.update = !(trace.intersected || trace.terminated || trace.suspended);