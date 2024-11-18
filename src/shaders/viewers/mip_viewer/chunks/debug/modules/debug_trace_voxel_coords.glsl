
vec3 debug_trace_voxel_coords = vec3(trace.voxel_coords) * u_volume.inv_dimensions;

debug.trace_voxel_coords = vec4(debug_trace_voxel_coords, 1.0);