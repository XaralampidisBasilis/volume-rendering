
// normalize ray min distance to the range [0, 1]
float ray_min_distance_norm = map(ray.global_min_distance, ray.global_max_distance, ray.min_distance);

debug.ray_min_distance = vec4(vec3(ray_min_distance_norm), 1.0);
