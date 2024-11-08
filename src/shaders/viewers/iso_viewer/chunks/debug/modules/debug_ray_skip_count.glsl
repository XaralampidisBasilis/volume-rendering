
// normalize trace steps to the range [0, 1]
float debug_ray_skip_count = float(ray.skip_count) / float(u_raymarch.max_skip_count);

debug.ray_skip_count = vec4(vec3(debug_ray_skip_count), 1.0);
