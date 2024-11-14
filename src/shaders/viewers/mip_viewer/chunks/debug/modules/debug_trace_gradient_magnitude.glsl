
// normalize trace gradient norm to the range [0, 1]
float debug_trace_gradient_magnitude = trace.gradient_magnitude / u_volume.max_gradient_magnitude;

debug.trace_gradient_magnitude = vec4(vec3(debug_trace_gradient_magnitude), 1.0);
