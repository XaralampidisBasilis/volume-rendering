
float debug_trace_distance = map(ray.min_start_distance, ray.max_end_distance, trace.distance);

debug.trace_distance = vec4(vec3(debug_trace_distance), 1.0);