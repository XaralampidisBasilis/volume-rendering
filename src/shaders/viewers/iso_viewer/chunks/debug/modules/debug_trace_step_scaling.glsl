
// normalize trace stepping to the range [0, 1]
float debug_trace_step_scaling = trace.step_scaling / u_raymarch.max_step_scaling;

debug.trace_step_scaling = vec4(vec3(debug_trace_step_scaling), 1.0);
