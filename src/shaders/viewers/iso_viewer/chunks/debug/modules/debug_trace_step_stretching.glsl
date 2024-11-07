
float debug_trace_step_stretching = trace.step_stretching / u_raymarch.max_step_stretching;

debug.trace_step_stretching = vec4(vec3(debug_trace_step_stretching), 1.0);
