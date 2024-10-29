
// normalize ray max steps in the range [0, 1]
float debug_ray_max_steps = float(ray.max_steps) / float(raymarch.max_steps);

debug.ray_max_steps = vec4(vec3(debug_ray_max_steps), 1.0);
