
trace.distance = ray.start_distance;
trace.position = camera.position + ray.direction * trace.distance;
mip = trace;

cell.coords = ivec3(trace.position * u_intensity_map.inv_spacing + 0.5);
cell.coords_step = ivec3(0);