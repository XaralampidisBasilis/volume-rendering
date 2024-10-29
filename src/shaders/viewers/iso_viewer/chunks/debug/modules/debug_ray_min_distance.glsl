
// normalize ray min distance to the range [0, 1]
float debug_ray_min_distance = map(ray.global_min_distance, ray.global_max_distance, ray.start_distance);

debug.ray_min_distance = vec4(vec3(debug_ray_min_distance), 1.0);
