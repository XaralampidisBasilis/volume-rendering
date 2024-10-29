

// normalize trace derivative to the range [0, 1]
float debug_trace_max_derivative_3rd = 1000.0 / pow3(length(volume.spacing));
float debug_trace_derivative_3rd = map(-1.0, 1.0, trace.derivative_3rd / debug_trace_max_derivative_3rd);

debug.trace_derivative_3rd = vec4(vec3(debug_trace_derivative_3rd), 1.0);
