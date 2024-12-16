
float debug_proj_trace_step_distance = proj_trace.step_distance / length(u_volume.spacing);

debug.proj_trace_step_distance = vec4(vec3(debug_proj_trace_step_distance), 1.0);
