
// normalize max depth in range [0, 1]
float ray_max_depth_norm = ray.max_depth / ray.max_max_depth;

debug.ray_max_depth = vec4(vec3(ray_max_depth_norm), 1.0);
