
vec3 debug_trace_position = map(ray.box_min_position, ray.box_max_position, trace.position);

debug.trace_position = vec4(debug_trace_position, 1.0);