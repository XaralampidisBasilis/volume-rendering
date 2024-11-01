
// normalize ray min distance to the range [0, 1]
float debug_ray_start_distance = map(ray.min_distance,ray.max_distance, ray.start_distance);

debug.ray_start_distance = vec4(vec3(debug_ray_start_distance), 1.0);
