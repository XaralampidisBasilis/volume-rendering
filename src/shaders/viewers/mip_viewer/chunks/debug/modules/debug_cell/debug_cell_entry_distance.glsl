
float debug_cell_entry_distance = map(box.min_entry_distance, box.max_exit_distance, cell.bounds.x);

debug.cell_entry_distance = vec4(vec3(debug_cell_entry_distance), 1.0);