
vec3 debug_trace_distance = map(box.min_entry_distance, box.max_exit_distance, vec3(trace.distance));
debug_trace_distance = mmix(RED_COLOR, BLACK_COLOR, WHITE_COLOR, map(-1.0, 1.0, debug_trace_distance));

debug.trace_distance = vec4(debug_trace_distance, 1.0);