
// normalize trace position to the range [0, 1]
vec3 debug_trace_position = trace.position * u_volume.inv_size;

debug.trace_position = vec4(debug_trace_position, 1.0);