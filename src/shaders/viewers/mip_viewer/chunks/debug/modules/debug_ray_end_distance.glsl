
// normalize ray max distance to the range [0, 1]
float debug_ray_end_distance = map(ray.min_start_distance, ray.max_end_distance, ray.end_distance);

debug.ray_end_distance = vec4(vec3(debug_ray_end_distance), 1.0);
