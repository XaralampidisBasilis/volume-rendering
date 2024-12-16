
float debug_box_min_entry_distance = map(camera.near_distance, camera.far_distance, box.min_entry_distance);;

debug.box_min_entry_distance = vec4(vec3(box.min_entry_distance), 1.0);

