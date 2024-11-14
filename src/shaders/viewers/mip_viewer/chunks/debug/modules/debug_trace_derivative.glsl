

// normalize trace derivative to the range [0, 1]
float debug_trace_derivative = map(-1.0, 1.0, trace.derivative / u_volume.max_gradient_magnitude);
vec3 debug_trace_derivative_color = mmix(CYAN_COLOR, BLACK_COLOR, MAGENTA_COLOR, debug_trace_derivative);

debug.trace_derivative = vec4(debug_trace_derivative_color, 1.0);
