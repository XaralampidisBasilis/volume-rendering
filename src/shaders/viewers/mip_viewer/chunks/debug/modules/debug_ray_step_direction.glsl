
// normalize ray direction to the range [0, 1]
vec3 debug_ray_step_direction = ray.step_direction * 0.5 + 0.5;

debug.ray_step_direction = vec4(debug_ray_step_direction, 1.0);
