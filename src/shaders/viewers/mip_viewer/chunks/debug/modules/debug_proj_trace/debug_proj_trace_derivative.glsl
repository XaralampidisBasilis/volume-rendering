

// normalize proj_trace derivative to the range [0, 1]
float debug_proj_trace_derivative = map(-1.0, 1.0, proj_trace.derivative / u_volume.max_gradient_length);
vec3 debug_proj_trace_derivative_color = mmix(CYAN_COLOR, BLACK_COLOR, MAGENTA_COLOR, debug_proj_trace_derivative);

debug.proj_trace_derivative = vec4(debug_proj_trace_derivative_color, 1.0);
