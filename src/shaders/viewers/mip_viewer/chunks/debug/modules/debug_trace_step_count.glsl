
// normalize trace steps to the range [0, 1]
float debug_trace_step_count = float(trace.step_count) / float(u_raymarch.max_step_count);

debug.trace_step_count = vec4(vec3(debug_trace_step_count), 1.0);
