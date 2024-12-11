
vec3 debug_trace_position = map(box.min_position, box.max_position, trace.position);

debug.trace_position = vec4(debug_trace_position, 1.0);