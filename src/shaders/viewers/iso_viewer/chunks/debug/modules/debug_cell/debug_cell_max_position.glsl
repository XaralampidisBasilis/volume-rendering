

vec3 debug_cell_min_position = map(box.min_position, box.max_position, cell.min_position);

debug.cell_min_position = vec4(debug_cell_min_position, 1.0);