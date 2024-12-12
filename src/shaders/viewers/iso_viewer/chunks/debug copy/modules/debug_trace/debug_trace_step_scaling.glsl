
float debug_trace_step_scaling = map(
    u_rendering.min_step_scaling, 
    u_rendering.max_step_scaling, 
    trace.step_scaling
);

debug.trace_step_scaling = vec4(vec3(debug_trace_step_scaling), 1.0);
