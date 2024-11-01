
float debug_trace_distance_diff = (trace.distance - trace_prev.distance) / length(volume.spacing);

debug.trace_distance_diff = vec4(vec3(debug_trace_distance_diff), 1.0);