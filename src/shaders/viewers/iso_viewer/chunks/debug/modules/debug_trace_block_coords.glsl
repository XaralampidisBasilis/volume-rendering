// normalize trace block coords to the range [0, 1]
vec3 debug_trace_block_coords = vec3(trace.block_coords) * volume.inv_dimensions;

debug.trace_block_coords = vec4(debug_trace_block_coords, 1.0);