
// normalize trace depth to the range [0, 1]
float trace_depth_norm = trace.depth / ray.max_max_depth;

debug.trace_depth = vec4(vec3(trace_depth_norm), 1.0);