
// normalize trace distance to the range [0, 1]
float debug_trace_distance = map(ray.box_min_distance, ray.box_max_distance, trace.distance);

debug.trace_distance = vec4(vec3(debug_trace_distance), 1.0);