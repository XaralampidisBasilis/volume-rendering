

// normalize trace derivative to the range [0, 1]
float debug_trace_max_derivative_2nd = 10.0 / pow2(length(volume.spacing));
float debug_trace_derivative_2nd = map(-1.0, 1.0, trace.derivative_2nd / debug_trace_max_derivative_2nd);

debug.trace_derivative_2nd = vec4(vec3(debug_trace_derivative_2nd), 1.0);
