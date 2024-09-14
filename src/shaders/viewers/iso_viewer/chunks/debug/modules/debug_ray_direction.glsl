
// normalize ray direction to the range [0, 1]
vec3 ray_direction_norm = ray.direction * 0.5 + 0.5;

debug.ray_direction = vec4(ray_direction_norm, 1.0);
