
float debug_trace_delta_distance = (trace.distance - prev_trace.distance) / u_volume.spacing_length;

debug.trace_delta_distance = vec4(vec3(debug_trace_delta_distance), 1.0);