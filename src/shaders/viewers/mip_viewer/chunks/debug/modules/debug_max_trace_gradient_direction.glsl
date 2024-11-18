
// normalize trace gradient to the range [0, 1]
vec3 debug_max_trace_gradient_direction = (max_trace.gradient_direction / u_volume.max_gradient_magnitude) * 0.5 + 0.5;

debug.max_trace_gradient_direction = vec4(debug_max_trace_gradient_direction, 1.0);
