
float debug_max_trace_step_count = float(max_trace.step_count) / float(u_raymarch.max_step_count);

debug.max_trace_step_count = vec4(vec3(debug_max_trace_step_count), 1.0);
