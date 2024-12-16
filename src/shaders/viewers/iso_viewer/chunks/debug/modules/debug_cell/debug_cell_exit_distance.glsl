
float debug_cell_exit_distance = map(box.min_entry_distance, box.max_exit_distance, cell.bounds.y);

debug.cell_exit_distance = vec4(vec3(debug_cell_exit_distance), 1.0);