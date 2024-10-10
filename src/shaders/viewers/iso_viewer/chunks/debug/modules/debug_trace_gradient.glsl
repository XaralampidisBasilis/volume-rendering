
// normalize trace gradient to the range [0, 1]
vec3 trace_gradient_normalized = (trace.gradient / u_gradient.max_norm) * 0.5 + 0.5;

debug.trace_gradient = vec4(trace_gradient_normalized, 1.0);
