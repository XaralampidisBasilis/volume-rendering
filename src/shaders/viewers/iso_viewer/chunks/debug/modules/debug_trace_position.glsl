
// normalize trace position to the range [0, 1]
vec3 trace_position_norm = trace.position * u_volume.inv_size;

debug.trace_position = vec4(trace_position_norm, 1.0);