
// normalize trace gradient norm to the range [0, 1]
float debug_trace_gradient_norm = trace.gradient_magnitude / volume.max_gradient_magnitude;

debug.trace_gradient_norm = vec4(vec3(debug_trace_gradient_norm), 1.0);
