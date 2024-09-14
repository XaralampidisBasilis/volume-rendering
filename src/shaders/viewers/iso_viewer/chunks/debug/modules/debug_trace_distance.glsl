
// normalize trace distance to the range [0, 1]
float trace_distance_norm = trace.distance / ray.max_box_distance;

debug.trace_distance = vec4(vec3(trace_distance_norm), 1.0);