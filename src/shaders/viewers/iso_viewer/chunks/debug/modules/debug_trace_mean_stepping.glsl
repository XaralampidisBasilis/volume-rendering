
// compute trace mean stepping 
float debug_trace_mean_stepping = (trace.depth / ray.spacing) / float(trace.steps);

// normalize trace mean stepping to the range [0, 1]
debug_trace_mean_stepping = map(u_raycast.min_stepping, u_raycast.max_stepping, debug_trace_mean_stepping);

debug.trace_mean_stepping = vec4(vec3(debug_trace_mean_stepping), 1.0);
