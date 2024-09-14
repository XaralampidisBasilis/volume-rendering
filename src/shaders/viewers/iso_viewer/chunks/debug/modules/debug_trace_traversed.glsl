
// normalize trace traversed to the range [0, 1]
float trace_traversed_norm = trace.traversed / ray.max_box_distance;

debug.trace_traversed = vec4(vec3(trace_traversed_norm), 1.0);
