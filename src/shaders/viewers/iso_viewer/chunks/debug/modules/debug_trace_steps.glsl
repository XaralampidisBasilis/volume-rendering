
// normalize trace steps to the range [0, 1]
float debug_trace_steps = float(trace.steps) / float(u_raycast.max_steps);

debug.trace_steps = vec4(vec3(debug_trace_steps), 1.0);
