
// normalize trace stepping to the range [0, 1]
float trace_stepping_norm = map(u_raycast.min_stepping, u_raycast.max_stepping, trace.stepping);

debug.trace_stepping = vec4(vec3(trace_stepping_norm), 1.0);
