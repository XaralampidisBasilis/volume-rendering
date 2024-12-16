
float debug_trace_distance = map(box.min_entry_distance, box.max_exit_distance, trace.distance);

debug.trace_distance = vec4(vec3(debug_trace_distance), 1.0);