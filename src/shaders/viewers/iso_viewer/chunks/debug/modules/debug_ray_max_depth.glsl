
// normalize max depth in range [0, 1]
float debug_ray_max_depth = ray.max_depth / ray.global_max_depth;

debug.ray_max_depth = vec4(vec3(debug_ray_max_depth), 1.0);
