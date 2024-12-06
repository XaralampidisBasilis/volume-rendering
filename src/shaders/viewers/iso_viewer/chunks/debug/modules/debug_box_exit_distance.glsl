
float debug_box_exit_distance = map(box.min_entry_distance, box.max_exit_distance, box.exit_distance);

debug.box_exit_position = vec4(vec3(debug_box_exit_distance), 1.0);
