

// normalize trace derivative to the range [0, 1]
float debug_max_trace_derivative = map(-1.0, 1.0, max_trace.derivative / u_volume.max_gradient_length);

debug.max_trace_derivative = vec4(mmix(CYAN_COLOR, BLACK_COLOR, MAGENTA_COLOR, debug_max_trace_derivative), 1.0);
