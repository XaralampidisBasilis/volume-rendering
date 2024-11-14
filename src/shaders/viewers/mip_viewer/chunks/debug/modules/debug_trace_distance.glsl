
// normalize trace distance to the range [0, 1]
float debug_trace_distance = trace.distance / ray.max_end_distance;

debug.trace_distance = vec4(vec3(debug_trace_distance), 1.0);