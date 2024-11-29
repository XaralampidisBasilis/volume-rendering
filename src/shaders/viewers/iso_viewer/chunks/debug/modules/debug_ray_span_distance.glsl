
// normalize max depth in range [0, 1]
float debug_ray_span_distance = ray.span_distance / ray.box_max_span;

debug.ray_span_distance = vec4(vec3(debug_ray_span_distance), 1.0);
