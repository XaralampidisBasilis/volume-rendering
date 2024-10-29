
// normalize ray dithering to the range [0, 1]
float debug_rand_distance = ray.rand_distance / ray.max_step_distance;

debug.ray_dithering = vec4(vec3(debug_rand_distance), 1.0);
