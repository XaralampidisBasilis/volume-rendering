
// normalize trace gradient to the range [0, 1]
vec3 trace_gradient_normalized = map(u_gradient.min_norm, u_gradient.max_norm, trace.gradient);
trace_gradient_normalized = trace_gradient_normalized * 0.5 + 0.5;

debug.trace_gradient = vec4(trace_gradient_normalized, 1.0);
