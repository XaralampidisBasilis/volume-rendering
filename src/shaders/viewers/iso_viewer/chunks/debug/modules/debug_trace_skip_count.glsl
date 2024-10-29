
// normalize trace steps to the range [0, 1]
float debug_trace_skip_count = float(trace.skip_count) / float(raymarch.max_skip_count);

debug.trace_skip_count = vec4(vec3(debug_trace_skip_count), 1.0);
