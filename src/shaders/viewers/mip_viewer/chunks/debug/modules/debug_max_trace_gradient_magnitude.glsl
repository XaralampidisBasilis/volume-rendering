
// normalize trace gradient norm to the range [0, 1]
float debug_max_trace_gradient_magnitude = max_trace.gradient_magnitude / u_volume.max_gradient_length;

debug.max_trace_gradient_magnitude = vec4(vec3(debug_max_trace_gradient_magnitude), 1.0);
