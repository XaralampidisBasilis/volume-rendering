
// normalize max depth in range [0, 1]
float debug_ray_box_span_distance = ray.box_span_distance / ray.max_span_distance;

debug.ray_box_span_distance = vec4(vec3(debug_ray_box_span_distance), 1.0);
