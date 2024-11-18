
vec3 debug_max_trace_voxel_coords = vec3(max_trace.voxel_coords) * u_volume.inv_dimensions;

debug.max_trace_voxel_coords = vec4(debug_max_trace_voxel_coords, 1.0);