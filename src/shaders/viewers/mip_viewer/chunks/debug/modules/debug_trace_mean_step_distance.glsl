
float debug_trace_mean_step_distance = (trace.distance / float(trace.step_count + 1)) * u_volume.inv_spacing_length;

debug.trace_mean_step_distance = vec4(vec3(debug_trace_mean_step_distance), 1.0);
