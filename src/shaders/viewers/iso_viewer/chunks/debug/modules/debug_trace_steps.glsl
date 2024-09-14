
// normalize trace steps to the range [0, 1]
float trace_steps_norm = float(trace.steps) / float(u_raycast.max_steps);

debug.trace_steps = vec4(vec3(trace_steps_norm), 1.0);
