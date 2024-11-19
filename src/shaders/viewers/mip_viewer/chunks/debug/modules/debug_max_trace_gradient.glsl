
// normalize trace gradient to the range [0, 1]
vec3 debug_max_trace_gradient = (max_trace.gradient / u_volume.max_gradient_length) * 0.5 + 0.5;

debug.max_trace_gradient = vec4(debug_max_trace_gradient, 1.0);
