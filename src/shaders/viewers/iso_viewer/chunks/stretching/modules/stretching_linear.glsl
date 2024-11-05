float trace_stretching_scale = 0.5 * length(volume.size);
trace.step_stretching = 1.0 + trace.distance / trace_stretching_scale;
trace.step_stretching = min(trace.step_stretching, raymarch.max_step_stretching);

