
// normalize trace stepping to the range [0, 1]
float debug_trace_stepping = map(u_raycast.min_stepping, u_raycast.max_stepping, trace.stepping);

debug.trace_stepping = vec4(vec3(debug_trace_stepping), 1.0);
