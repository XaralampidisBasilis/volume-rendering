
float debug_box_span_distance = map(0.0, box.max_span_distance, box.span_distance);

debug.box_span_distance = vec4(vec3(debug_box_span_distance), 1.0);
