

vec3 debug_cell_max_position = map(box.min_position, box.max_position, cell.max_position);

debug.cell_max_position = vec4(debug_cell_max_position, 1.0);