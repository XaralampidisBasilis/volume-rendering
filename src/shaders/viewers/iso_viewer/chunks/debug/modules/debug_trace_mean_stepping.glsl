
// compute trace mean stepping 
float trace_mean_stepping = (trace.depth / ray.spacing) / float(trace.steps);

// normalize trace mean stepping to the range [0, 1]
float trace_mean_stepping_norm = map(u_raycast.min_stepping, u_raycast.max_stepping, trace_mean_stepping);

debug.trace_mean_stepping = vec4(vec3(trace_mean_stepping_norm), 1.0);
