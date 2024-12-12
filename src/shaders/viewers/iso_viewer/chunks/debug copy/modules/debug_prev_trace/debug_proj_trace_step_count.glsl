
// normalize proj_trace steps to the range [0, 1]
float debug_proj_trace_step_count = float(proj_trace.step_count) / float(u_rendering.max_step_count);

debug.proj_trace_step_count = vec4(vec3(debug_proj_trace_step_count), 1.0);
