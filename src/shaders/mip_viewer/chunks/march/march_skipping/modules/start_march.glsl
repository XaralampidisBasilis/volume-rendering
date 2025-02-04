
// Start trace and mip from ray
trace.distance = ray.start_distance;
trace.position = ray.start_position;
mip = trace;

// Start block from trace
block.coords = ivec3((trace.position + u_intensity_map.spacing * 0.5) * u_maxima_map.inv_spacing);
block.coords_step = ivec3(0);
block.exit_distance = trace.distance;