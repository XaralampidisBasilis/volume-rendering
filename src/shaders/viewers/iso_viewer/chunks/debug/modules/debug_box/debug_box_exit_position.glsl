
vec3 debug_box_exit_position = map(box.min_position, box.max_position, box.exit_position);

debug.box_exit_position = vec4(debug_box_exit_position, 1.0);
