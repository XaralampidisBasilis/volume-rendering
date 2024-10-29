
// normalize trace depth to the range [0, 1]
float deug_trace_depth = trace.depth / ray.max_span_distance;

debug.trace_depth = vec4(vec3(deug_trace_depth), 1.0);