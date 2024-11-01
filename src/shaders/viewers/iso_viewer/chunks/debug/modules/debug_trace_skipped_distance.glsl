
// normalize trace skipped to the range [0, 1]
float debug_trace_skipped_distance = trace.skipped_distance / (ray.box_max_distance - ray.box_min_distance);

debug.trace_skipped_distance = vec4(vec3(debug_trace_skipped_distance), 1.0);
