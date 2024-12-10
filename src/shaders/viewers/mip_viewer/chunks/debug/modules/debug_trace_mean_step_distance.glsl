
float debug_trace_mean_step_distance = trace.mean_step_distance / u_volume.spacing_length;

debug.trace_mean_step_distance = vec4(vec3(debug_trace_mean_step_distance), 1.0);
