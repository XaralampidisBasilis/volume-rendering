
vec3 debug_trace_step_distance = vec3(trace.step_distance / length(u_volume.spacing));
debug_trace_step_distance = mmix(RED_COLOR, BLACK_COLOR, WHITE_COLOR, map(-1.0, 1.0, debug_trace_step_distance));

debug.trace_step_distance = vec4(debug_trace_step_distance, 1.0);
