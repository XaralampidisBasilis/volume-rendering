
float debug_box_entry_distance = map(box.min_entry_distance, box.max_exit_distance, box.entry_distance);

debug.box_entry_distance = vec4(vec3(debug_box_entry_distance), 1.0);
