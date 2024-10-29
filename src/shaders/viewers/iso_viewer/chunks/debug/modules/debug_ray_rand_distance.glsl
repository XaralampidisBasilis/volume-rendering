
// normalize ray dithering to the range [0, 1]
float debug_ray_rand_distance = ray.rand_distance / ray.max_step_distance;

debug.ray_rand_distance = vec4(vec3(debug_ray_rand_distance), 1.0);
