// start count
trace.step_count = 0;
trace.skip_count = 0;

// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// sample volume at start position
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - u_raymarch.sample_threshold;

// sample gradient
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;

// compute step stretching 
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_stretching"
#endif

// compute step sclaling
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update trace step distance
trace.step_distance = ray.step_distance * trace.step_scaling;
trace.mean_step_scaling += trace.step_scaling;
trace.mean_step_distance += trace.step_distance;

// check conditions
trace.terminated = trace.distance > ray.end_distance;
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
trace.update = !(trace.intersected || trace.terminated);