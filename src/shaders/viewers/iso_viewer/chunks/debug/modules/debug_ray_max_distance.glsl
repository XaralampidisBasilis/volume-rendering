
// normalize ray max distance to the range [0, 1]
float debug_ray_max_distance = map(ray.global_min_distance, ray.global_max_distance, ray.max_distance);

debug.ray_max_distance = vec4(vec3(debug_ray_max_distance), 1.0);
