block.coords = ivec3((trace.position + u_intensity_map.spacing * 0.5) * u_maxima_map.inv_spacing);
block.coords_step = ivec3(0);