
float debug_ray_max_skip_count = float(ray.max_skip_count) / float(u_rendering.max_skip_count);

debug.ray_max_skip_count = vec4(vec3(debug_ray_max_skip_count), 1.0);
