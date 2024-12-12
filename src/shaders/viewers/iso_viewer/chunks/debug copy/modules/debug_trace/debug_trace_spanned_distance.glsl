
float debug_trace_spanned_distance = map(0.0, box.max_span_distance, trace.distance - ray.start_distance);

debug.trace_spanned_distance = vec4(vec3(debug_trace_spanned_distance), 1.0);
