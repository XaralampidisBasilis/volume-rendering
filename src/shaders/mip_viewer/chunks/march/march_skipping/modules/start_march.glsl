
// initialize trace and mip from ray start distance
trace.distance = ray.start_distance;
trace.position = camera.position + ray.direction * trace.distance;
mip = trace;

// initialize cell from trace position
cell.coords = ivec3(trace.position * u_intensity_map.inv_spacing + 0.5);
cell.coords_step = ivec3(0);

// initialize block from trace position
block.coords = ivec3((trace.position + u_intensity_map.spacing * 0.5) * u_maxima_map.inv_spacing);
block.coords_step = ivec3(0);
