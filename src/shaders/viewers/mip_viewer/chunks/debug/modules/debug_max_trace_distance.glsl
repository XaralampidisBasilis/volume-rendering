
float debug_max_trace_distance = map(ray.min_start_distance, ray.max_end_distance, max_trace.distance);

debug.max_trace_distance = vec4(vec3(debug_max_trace_distance), 1.0);