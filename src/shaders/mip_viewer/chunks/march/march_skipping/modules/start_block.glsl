
// compute current block based on current cell coordinates
block.coords = (cell.coords + cell.coords_step) / u_maxima_map.sub_division;
block.coords_step = ivec3(0);