
float debug_proj_trace_distance = map(box.min_entry_distance, box.max_exit_distance, proj_trace.distance);

debug.proj_trace_distance = vec4(vec3(debug_proj_trace_distance), 1.0);