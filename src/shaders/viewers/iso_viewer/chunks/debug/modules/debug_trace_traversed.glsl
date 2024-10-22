
// normalize trace traversed to the range [0, 1]
float debug_trace_traversed = trace.depth - trace.skipped;
debug_trace_traversed = debug_trace_traversed / ray.global_max_depth;

debug.trace_traversed = vec4(vec3(debug_trace_traversed), 1.0);
