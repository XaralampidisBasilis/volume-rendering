
vec4 debug_cell_distances = map(cell.bounds.x, cell.bounds.y, cell.distances);

debug.cell_distances = vec4(debug_cell_distances.xyz, 1.0);