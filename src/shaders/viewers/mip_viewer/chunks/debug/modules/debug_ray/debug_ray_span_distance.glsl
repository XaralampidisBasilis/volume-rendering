
float debug_ray_span_distance = map(0.0, box.max_span_distance, ray.span_distance);

debug.ray_span_distance = vec4(vec3(debug_ray_span_distance), 1.0);
