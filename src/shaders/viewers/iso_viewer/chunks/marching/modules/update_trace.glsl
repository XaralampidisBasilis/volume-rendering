// compute step stretching factor based on distance
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_streching"
#endif

// compute step sclaling factor based on gradients
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update step distance
trace.step_distance = ray.step_distance * trace.step_scaling;
trace.mean_step_scaling += trace.step_scaling;
trace.mean_step_distance += trace.step_distance;
trace.step_count++;
trace.suspended = trace.step_count >= ray.max_step_count;

// update position
trace.distance += trace.step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.step_distance * ray.step_direction; // accumulates numerical errors
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;
trace.terminated = trace.distance > ray.end_distance;

// update sample data
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - u_raymarch.sample_threshold;
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;

// update gradient
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;

// check conditions
trace.update = !(trace.intersected || trace.terminated || trace.suspended);
