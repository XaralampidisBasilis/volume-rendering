
// trace.step_stretching = 1.0 + 2.0 * trace.distance * u_volume.inv_size_length;
// trace.step_stretching = exp(2.0 * trace.distance * u_volume.inv_size_length);

// trace.step_stretching = clamp(0.0, 1.0, trace.distance / ray.box_max_distance);
trace.step_stretching = clamp(0.0, 1.0, exp(trace.distance / ray.box_max_distance) - 1.0);

ray.max_step_scaling = mix(u_raymarch.min_step_scaling, u_raymarch.max_step_scaling, trace.step_stretching);