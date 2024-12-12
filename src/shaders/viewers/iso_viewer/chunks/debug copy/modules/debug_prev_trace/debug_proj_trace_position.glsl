
vec3 debug_proj_trace_position = map(box.min_position, box.max_position, proj_trace.position);

debug.proj_trace_position = vec4(debug_proj_trace_position, 1.0);