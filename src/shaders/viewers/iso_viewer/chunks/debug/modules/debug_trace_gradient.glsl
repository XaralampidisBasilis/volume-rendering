
// normalize trace gradient to the range [0, 1]
vec3 debug_trace_gradient = (trace.gradient / volume.max_gradient_magnitude) * 0.5 + 0.5;

debug.trace_gradient = vec4(debug_trace_gradient, 1.0);
