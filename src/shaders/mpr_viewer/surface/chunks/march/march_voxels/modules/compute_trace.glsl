
// Compute trace from voxel
trace.distance = voxel.entry_distance;
trace.position = voxel.entry_position;

// Compute trace coords and uvw
trace.coords = ivec3(trace.position * u_intensity_map.inv_spacing);
trace.uvw = trace.position * u_intensity_map.inv_size;
