

vec3 debug_trace_derivative = mmix(CYAN_COLOR, BLACK_COLOR, MAGENTA_COLOR, map(-1.0, 1.0, trace.derivative / u_volume.max_gradient_length));

debug.trace_derivative = vec4(debug_trace_derivative, 1.0);
