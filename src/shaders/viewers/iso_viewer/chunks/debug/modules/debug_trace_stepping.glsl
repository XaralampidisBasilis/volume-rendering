
// normalize trace stepping to the range [0, 1]
float debug_trace_stepping = map(raymarch.min_step_scale, raymarch.max_step_scale, trace.step_scaling);

debug.trace_stepping = vec4(vec3(debug_trace_stepping), 1.0);
