
// normalize ray max steps in the range [0, 1]
float debug_ray_max_step_count = float(ray.max_step_count) / float(raymarch.max_step_count);

debug.ray_max_step_count = vec4(vec3(debug_ray_max_step_count), 1.0);
