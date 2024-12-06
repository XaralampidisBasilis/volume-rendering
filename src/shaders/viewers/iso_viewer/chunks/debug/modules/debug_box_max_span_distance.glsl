
float debug_box_max_span_distance = map(camera.near_distance, camera.far_distance, box.max_span_distance);

debug.box_max_span_distance = vec4(vec3(box.max_span_distance), 1.0);

