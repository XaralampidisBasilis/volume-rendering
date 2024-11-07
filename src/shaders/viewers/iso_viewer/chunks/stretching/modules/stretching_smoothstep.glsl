float trace_stretching_scale = 0.5 * length(u_volume.size);
trace.step_stretching = 1.0 + smoothstep(0.0, ray.box_max_distance, trace.distance / trace_stretching_scale);
trace.step_stretching = min(trace.step_stretching, u_raymarch.max_step_stretching);

