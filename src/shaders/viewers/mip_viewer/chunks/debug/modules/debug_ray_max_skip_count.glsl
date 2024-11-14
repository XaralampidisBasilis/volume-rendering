
// normalize ray max steps in the range [0, 1]
float debug_ray_max_skip_count = float(ray.max_skip_count) / float(u_raymarch.max_skip_count);

debug.ray_max_skip_count = vec4(vec3(debug_ray_max_skip_count), 1.0);
