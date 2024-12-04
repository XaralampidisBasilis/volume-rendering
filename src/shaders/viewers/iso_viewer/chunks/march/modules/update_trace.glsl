// update previous trace
prev_trace.distance = trace.distance;
prev_trace.value = trace.value;

// update position
trace.distance += trace.step_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;
vec4 taylormap_sample = texture(u_textures.taylormap, trace.voxel_texels);

// update value
trace.value = taylormap_sample.r;
trace.value_error = trace.value - u_rendering.min_value;

// update gradient
trace.gradient = taylormap_sample.gba;
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.gradient);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;

// update step
#if TRACE_STEPPING_ENABLED == 1
#include "./compute_trace_step"
#else
trace.step_distance = ray.step_distance;
#endif

// update conditions
trace.suspended = trace.step_count >= u_rendering.max_step_count;
trace.terminated = trace.distance > ray.end_distance;
trace.intersected = trace.value_error > 0.0;
trace.update = !trace.intersected && !trace.terminated && !trace.suspended;

// update cumulative stats
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;
trace.mean_step_scaling = trace.step_scaling + trace.mean_step_scaling * float(trace.step_count);
trace.mean_step_distance = trace.step_distance + trace.mean_step_distance * float(trace.step_count);
trace.mean_step_scaling /= float(trace.step_count + 1);
trace.mean_step_distance /= float(trace.step_count + 1);
