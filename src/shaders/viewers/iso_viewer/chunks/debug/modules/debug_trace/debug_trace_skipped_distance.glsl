
float debug_trace_skipped_distance = map(0.0, box.max_span_distance, trace.skipped_distance);

debug.trace_skipped_distance = vec4(vec3(debug_trace_skipped_distance), 1.0);
