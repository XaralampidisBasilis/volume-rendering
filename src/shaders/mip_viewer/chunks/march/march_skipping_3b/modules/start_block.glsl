
block.exit_distance = ray.start_distance;
block.exit_position = ray.start_position;

block.coords = ivec3((ray.start_position + u_intensity_map.spacing * 0.5) * u_maxima_map.inv_spacing);
block.coords_step = ivec3(0);
