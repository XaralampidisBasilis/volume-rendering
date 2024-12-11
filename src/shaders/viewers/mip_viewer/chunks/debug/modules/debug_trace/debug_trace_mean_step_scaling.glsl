
// normalize trace stepping to the range [0, 1]
float debug_trace_mean_step_scaling = map(
    u_rendering.min_step_scaling, 
    u_rendering.max_step_scaling, 
    trace.mean_step_scaling
);

debug.trace_mean_step_scaling = vec4(vec3(debug_trace_mean_step_scaling), 1.0);
