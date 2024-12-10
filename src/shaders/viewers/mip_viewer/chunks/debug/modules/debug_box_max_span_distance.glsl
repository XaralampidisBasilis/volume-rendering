
float debug_box_max_span_distance = map(0.0, camera.far_distance - camera.near_distance, box.max_span_distance);

debug.box_max_span_distance = vec4(vec3(box.max_span_distance), 1.0);

