
float debug_box_max_exit_distance = map(camera.near_distance, camera.far_distance, box.max_exit_distance);

debug.box_max_exit_distance = vec4(vec3(box.max_exit_distance), 1.0);

