

// normalize trace derivative to the range [0, 1]
float debug_trace_max_derivative2 = 10.0 / pow2(length(u_volume.spacing));
float debug_trace_derivative2 = map(-1.0, 1.0, trace.derivative_2nd / debug_trace_max_derivative2);

debug.trace_derivative2 = vec4(vec3(debug_trace_derivative2), 1.0);
