
// compute current block based on current trace position
block.coords = ivec3((trace.position + u_intensity_map.spacing * 0.5) * u_maxima_map.inv_spacing);
block.coords_step = ivec3(0);

// compute current block based on current cell coordinates
// block.coords = (cell.coords + cell.coords_step) / u_maxima_map.sub_division;
// block.coords_step = ivec3(0);