
// compute trace mean stepping 
float debug_trace_mean_stepping = (trace.depth / ray.step_distance) / float(trace.step_count);

// normalize trace mean stepping to the range [0, 1]
debug_trace_mean_stepping = map(raymarch.min_step_scale, raymarch.max_step_scale, debug_trace_mean_stepping);

debug.trace_mean_stepping = vec4(vec3(debug_trace_mean_stepping), 1.0);
