
// normalize trace gradient norm to the range [0, 1]
float debug_trace_gradient_norm = trace.gradient_norm / u_gradient.max_norm;

debug.trace_gradient_norm = vec4(vec3(debug_trace_gradient_norm), 1.0);
