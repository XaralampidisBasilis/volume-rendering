
// normalize trace skipped to the range [0, 1]
float trace_skipped_norm = trace.skipped / ray.max_max_distance;

debug.trace_skipped = vec4(vec3(trace_skipped_norm), 1.0);
