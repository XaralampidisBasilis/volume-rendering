
float debug_box_entry_position = map(box.min_position, box.max_position, box.entry_position);

debug.box_entry_position = vec4(vec3(debug_box_entry_position), 1.0);
