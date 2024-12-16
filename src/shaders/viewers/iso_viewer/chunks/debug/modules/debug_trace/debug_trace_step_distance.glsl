
float debug_trace_step_distance = trace.step_distance / length(u_volume.spacing);

debug.trace_step_distance = vec4(vec3(debug_trace_step_distance), 1.0);
