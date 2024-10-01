
// normalize ray max distance to the range [0, 1]
float ray_max_distance_norm = map(ray.min_min_distance, ray.max_max_distance, ray.max_distance);

debug.ray_max_distance = vec4(vec3(ray_max_distance_norm), 1.0);
