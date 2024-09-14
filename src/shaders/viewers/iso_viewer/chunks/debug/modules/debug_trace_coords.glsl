// normalize trace coords to the range [0, 1]
vec3 trace_coords_norm = trace.coords * u_volume.inv_dimensions;

debug.trace_coords = vec4(trace_coords_norm, 1.0);