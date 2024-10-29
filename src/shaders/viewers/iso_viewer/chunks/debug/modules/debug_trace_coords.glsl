// normalize trace coords to the range [0, 1]
vec3 debug_trace_coords = trace.voxel_coords * u_volume.inv_dimensions;

debug.trace_coords = vec4(debug_trace_coords, 1.0);