

// normalize trace derivative to the range [0, 1]
float debug_trace_derivative_1st = map(-1.0, 1.0, trace.derivative_1st / u_volume.max_gradient_magnitude);

debug.trace_derivative_1st = vec4(vec3(debug_trace_derivative_1st), 1.0);
