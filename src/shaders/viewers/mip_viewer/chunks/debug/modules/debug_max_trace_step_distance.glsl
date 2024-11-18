
float debug_max_trace_step_distance = max_trace.step_distance * u_volume.inv_spacing_length;

debug.max_trace_step_distance = vec4(vec3(debug_max_trace_step_distance), 1.0);
