
vec3 debug_max_trace_position = map(ray.box_min_position, ray.box_max_position, max_trace.position);

debug.max_trace_position = vec4(debug_max_trace_position, 1.0);