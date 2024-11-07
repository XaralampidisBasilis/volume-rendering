
float trace_stretching_scale = 0.3 * length(u_volume.size);
trace.step_stretching = 1.0 + trace.distance / trace_stretching_scale;

