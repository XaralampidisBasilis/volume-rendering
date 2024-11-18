
float debug_trace_distance_diff = (trace.distance) / length(u_volume.spacing);

debug.trace_distance_diff = vec4(vec3(debug_trace_distance_diff), 1.0);