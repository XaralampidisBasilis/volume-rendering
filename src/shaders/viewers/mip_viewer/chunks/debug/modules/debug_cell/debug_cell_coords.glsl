
vec3 debug_cell_coords = vec3(cell.coords) * u_volume.inv_dimensions;

debug.cell_coords = vec4(debug_cell_coords, 1.0);