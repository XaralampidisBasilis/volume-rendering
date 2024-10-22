

// normalize trace derivative to the range [0, 1]
float debug_trace_derivative = map(-1.0, 1.0, trace.derivative / u_gradient.max_norm);

debug.trace_derivative = vec4(vec3(debug_trace_derivative), 1.0);
