

// normalize trace derivative to the range [0, 1]
float debug_trace_max_derivative3 = 1000.0 / pow3(length(u_volume.spacing));
float debug_trace_derivative3 = map(-1.0, 1.0, trace.derivative_3rd / debug_trace_max_derivative3);

debug.trace_derivative3 = vec4(vec3(debug_trace_derivative3), 1.0);
