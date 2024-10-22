
// normalize trace skipped to the range [0, 1]
float debug_trace_skipped = trace.skipped / ray.global_max_depth;

debug.trace_skipped = vec4(vec3(debug_trace_skipped), 1.0);
