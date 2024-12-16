
float debug_cell_distances = map(cell.bounds.x, cell.bounds.y, cell.distances);

debug.cell_distances = vec4(vec3(debug_cell_distances), 1.0);